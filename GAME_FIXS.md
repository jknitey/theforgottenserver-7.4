NPC shop fix

Problem

NPC buying and selling prompts worked up to the confirmation question, but replying with `yes` did nothing.

Example:

- `hi`
- `buy rope`
- NPC replied: `Do you want to buy 1 rope for 50 gold coins?`
- `yes`
- No purchase happened

What was happening

The NPC shop flow stores the current conversation node in `KeywordHandler.lastNode` after `buy rope` or `sell mace`.

That state was being keyed by raw Lua `cid` values. In this server branch, `cid` arrives in Lua as `userdata`, not a stable numeric player id. The `userdata` instance used when the player said `buy rope` was not reliably the same table key as the `userdata` instance used when the player later said `yes`.

Result:

- `ShopModule.tradeItem` ran correctly for `buy rope`
- the follow-up `yes` could not find the stored child node
- `ShopModule.onConfirm` never ran

How it was diagnosed

Temporary debug prints were added to the shop flow:

- `ShopModule.tradeItem` printed for `buy rope`
- `ShopModule.onConfirm` never printed for `yes`

That proved the shop logic itself was not the first problem. The failure was in NPC conversation state tracking between the initial shop message and the confirmation reply.

Fix

The NPC system was updated to normalize conversation state to a stable per-player key.

Changes made:

- `server/data/npc/lib/npcsystem/keywordhandler.lua`
  - added a helper that converts `cid` to a stable player id
  - used that normalized key for `lastNode`
- `server/data/npc/lib/npcsystem/npchandler.lua`
  - added the same stable-key normalization
  - changed focus checks to compare normalized keys instead of raw `userdata`

Additional compatibility fixes

While tracing the issue, missing shop compatibility helpers were also restored in:

- `server/data/npc/lib/_npcsystem.lua`

Those helpers include:

- `doPlayerBuyItem`
- `doPlayerBuyItemContainer`
- `doPlayerSellItem`
- `getBooleanFromString`
- `doNpcSetCreatureFocus`

Outcome

After the stable-key fix, NPC shop confirmation started working again:

- `buy ...` still opens the confirmation prompt
- `yes` now correctly reaches `ShopModule.onConfirm`
- buying and selling complete as expected

Boat travel fix

Problem

Boat captains would answer destination keywords, but some routes failed when the player replied with `yes`.

Examples:

- `thais -> venore` worked
- `venore -> edron` worked
- `venore -> thais` did not work
- `venore -> carlin` did not work
- `thais -> edron` worked
- after arriving in `edron`, other routes did not work
- after arriving in `carlin`, other routes did not work

What was happening

There were two separate problems in the imported boat scripts.

First:

- most captains still used the old nested `keywordHandler:addKeyword(...):addChildKeyword({'yes'}, StdModule.travel, ...)` flow
- in this server branch, that legacy conversation chain was unreliable for boat travel across multiple captain scripts
- the player could get the confirmation prompt, but the follow-up `yes` often did nothing

Second:

- several destination positions were copied from older boat scripts and landed on the wrong deck or on bad dock tiles
- some routes pointed to `z = 6` while the usable captain deck in this map was `z = 7`
- some destination tiles were also better represented by landing beside the destination captain instead of on the old boat coordinate

Result:

- one captain could work while the next captain in the chain still trapped the player
- successful travel to one town did not prove the rest of the ship network was valid

How it was diagnosed

The issue was traced route by route:

- `thais -> venore` succeeded, which proved the player could travel at all
- `venore -> thais` and `venore -> carlin` failed, while `venore -> edron` succeeded
- that showed the problem was no longer generic NPC chat handling, but a mix of legacy boat logic and bad destination tiles

The replacement `barco_thais.lua` script was also tested in isolation with `luajit` using stubbed NPC/game functions.

That verified:

- destination selection worked
- `yes` reached the travel callback
- `doTeleportThing(...)` was called with the expected destination

Fix

The affected captain scripts were converted from the fragile nested boat system to direct callback-based travel handlers.

Changes made:

- `server/data/npc/scripts/barco_thais.lua`
- `server/data/npc/scripts/barco_venore.lua`
- `server/data/npc/scripts/barco_edron.lua`
- `server/data/npc/scripts/barco_carlin.lua`

Each replacement script now:

- stores the pending destination per player using a stable player id key
- handles `destination -> yes/no` directly in `creatureSayCallback`
- teleports the player without relying on the old `StdModule.travel` child-keyword chain

Destination coordinates were also normalized to land beside the destination captain on the correct deck when needed.

Examples:

- Thais captain routes were switched to the direct travel handler
- Venore captain routes were updated to same-deck captain-adjacent tiles
- Edron captain routes were updated to same-deck captain-adjacent tiles
- Carlin captain routes were updated to same-deck captain-adjacent tiles

Outcome

After the boat fix:

- captains no longer depend on the broken legacy nested travel confirmation flow
- route handling is consistent across converted towns
- travel failures are no longer caused by the old captain scripts for Thais, Venore, Edron, and Carlin
- route destinations now target practical landing tiles near the destination captains instead of the imported deck coordinates that were failing on this map

Depot item placement fix

Problem

Items inserted directly into `player_depotitems` did not appear in the expected depot.

Example:

- A new character named `Arrow` was created in Thais.
- `Arrow` had `town_id = 3` and was positioned in Thais.
- Ten backpacks full of arrows were inserted into `player_depotitems` using `pid = 3` because `town_id = 3` looked like the Thais depot id.
- The SQL insert succeeded and `210` depot item rows existed, but the backpacks did not appear in the Thais depot in-game.

What was happening

The `players.town_id` value is not the same thing as the depot container id used by `player_depotitems.pid`.

For this server/database:

- `players.town_id = 3` means the character belongs to Thais.
- `player_depotitems.pid` is the depot/container parent id.
- The Thais depot being opened in-game was using `pid = 2`, not `pid = 3`.

This caused the backpacks to be inserted successfully, but into the wrong depot container from the game client's point of view.

How it was diagnosed

The character location was checked:

```sql
SELECT name, town_id, posx, posy, posz
FROM players
WHERE name = 'Arrow';
```

`Arrow` was confirmed to be in Thais with `town_id = 3`.

Then the depot table was inspected:

```sql
SELECT player_id, pid, sid, itemtype, count
FROM player_depotitems
WHERE player_id = (SELECT id FROM players WHERE name = 'Arrow')
ORDER BY pid, sid;
```

An existing depot item showed up under `pid = 2`, which revealed that the depot container id used by the Thais depot was `2`.

Fix

Insert the top-level depot backpacks with `pid = 2`, then insert arrows inside each backpack by using the backpack's `sid` as the child item `pid`.

Important pattern:

- Top-level backpack in depot: `pid = 2`
- Backpack id: `sid = 101`, `102`, `103`, etc.
- Items inside a backpack: `pid = backpack sid`

Working SQL:

```sql
SET @arrow_id = (SELECT id FROM players WHERE name = 'Arrow');

DELETE FROM player_depotitems
WHERE player_id = @arrow_id;

DELIMITER //

CREATE PROCEDURE add_arrow_depot_clean()
BEGIN
  DECLARE b INT DEFAULT 0;
  DECLARE s INT DEFAULT 0;
  DECLARE bp_sid INT;
  DECLARE item_sid INT;

  WHILE b < 10 DO
    SET bp_sid = 101 + b;

    -- Backpack directly in the Thais depot container.
    INSERT INTO player_depotitems
    (player_id, pid, sid, itemtype, count, attributes)
    VALUES
    (@arrow_id, 2, bp_sid, 1988, 1, '');

    SET s = 1;

    -- 20 stacks of 100 arrows inside each backpack.
    WHILE s <= 20 DO
      SET item_sid = 1000 + (b * 100) + s;

      INSERT INTO player_depotitems
      (player_id, pid, sid, itemtype, count, attributes)
      VALUES
      (@arrow_id, bp_sid, item_sid, 2544, 100, '');

      SET s = s + 1;
    END WHILE;

    SET b = b + 1;
  END WHILE;
END//

DELIMITER ;

CALL add_arrow_depot_clean();

DROP PROCEDURE add_arrow_depot_clean;
```

Validation

Check the total number of depot rows:

```sql
SELECT COUNT(*) AS depot_item_count
FROM player_depotitems
WHERE player_id = (SELECT id FROM players WHERE name = 'Arrow');
```

Expected result:

```text
210
```

That represents:

- 10 backpacks
- 200 arrow stacks
- 20 arrow stacks per backpack

Check the top-level depot backpacks:

```sql
SELECT player_id, pid, sid, itemtype, count
FROM player_depotitems
WHERE player_id = (SELECT id FROM players WHERE name = 'Arrow')
  AND itemtype = 1988
ORDER BY sid;
```

Expected pattern:

```text
pid = 2, sid = 101, itemtype = 1988
pid = 2, sid = 102, itemtype = 1988
pid = 2, sid = 103, itemtype = 1988
...
```

Check the arrows inside the backpacks:

```sql
SELECT player_id, pid, sid, itemtype, count
FROM player_depotitems
WHERE player_id = (SELECT id FROM players WHERE name = 'Arrow')
  AND itemtype = 2544
ORDER BY pid, sid;
```

Expected pattern:

```text
pid = 101, itemtype = 2544
pid = 102, itemtype = 2544
pid = 103, itemtype = 2544
...
```

Outcome

After using `pid = 2` for the top-level depot backpacks, the backpacks appeared in the Thais depot correctly.

Key lesson

Do not assume `players.town_id` equals `player_depotitems.pid`.

To find the correct depot id for a town:

1. Put a small test item into that depot in-game.
2. Log out and stop the server so it saves.
3. Query `player_depotitems` for the character.
4. Use the observed top-level `pid` as the correct depot container id.
