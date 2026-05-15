# Grimm Chronicles — Cases 004–012
*Bulk case file for Godot agent import*

---

# Case 004 — "Red in the Snow"
**Killer Wesen:** Blutbad | **Chapter:** 1 | **Difficulty:** Easy

## META
```json
"case_id": "case_004",
"case_title": "Red in the Snow",
"chapter": 1,
"difficulty": "easy",
"killer_wesen": "Blutbad",
"fairy_tale_hook": "Little Red Riding Hood — a wolf who cannot help what it is"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "Forest path outside the village. Fresh snow. Blood trail starts at the treeline and ends at a collapsed body 40 feet in.",

"victim": {
  "name": "Willem Roth",
  "wesen_type": "Bauerschwein (Pig)",
  "occupation": "Grain merchant, age 41",
  "condition": "Mauled. Deep claw lacerations across chest and shoulders. Expression of pure terror. Body partially dragged then abandoned. One boot missing."
},

"opening_description": "The snow remembers everything. Willem Roth made it forty feet from the treeline before whatever was behind him caught him. The blood trail is wide and unhurried — whatever did this was not in a hurry after the first strike. The claw marks are too far apart for any wolf. Too deep for any bear. And bears don't drag their kills forty feet and then just leave them.",

"time_of_death": "Between 9pm and 11pm — snow began falling at 10pm, partially obscuring the trail",
"environmental_hazard": "Dense forest — low visibility, movement slowed off-path"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Claw spacing on chest wounds is 28cm — far beyond any natural wolf or bear. Pattern is consistent with a single swipe from a large bipedal attacker.",
    "points_to": "Blutbad",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "A smell of wet fur and musk around the attack site — distinct, not a natural forest smell. Strongest at the point of first contact.",
    "points_to": "Blutbad",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "Red eye-shine captured in a witness's lantern at the treeline around 10pm. Not an animal reflection — too high off the ground, too steady.",
    "points_to": "Blutbad",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "Willem's boot found 200 feet deeper in the forest — the drag was abandoned when the attacker heard something. A church bell rang at 11pm.",
    "points_to": "Blutbad",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "Torn fabric from a heavy dark coat caught on a branch at chest height — not the victim's. Coarse wool, quality cut.",
    "points_to": "red_herring_suspect_1",
    "found_by_default": true
  },
  {
    "clue_id": "clue_006",
    "description": "Willem had recently won a contract dispute against the local miller, cutting him out of a profitable grain route. The miller made threats.",
    "points_to": "red_herring_suspect_2",
    "found_by_default": true
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "child_witness",
    "dialogue_key": "dlg_child_001",
    "clue_revealed": "I saw a big man go into the trees right before I heard the screaming. He walked funny — hunched, like his back hurt him.",
    "unlocked_by": null
  },
  {
    "witness_id": "innkeeper",
    "dialogue_key": "dlg_inn_001",
    "clue_revealed": "Karl Metz was in here all evening until about half-nine. Drank three cups, paid his tab, left heading toward the mill road.",
    "unlocked_by": null
  },
  {
    "witness_id": "innkeeper",
    "dialogue_key": "dlg_inn_002",
    "clue_revealed": "He seemed agitated. Kept looking at the door. And his eyes — the firelight caught them strange. Almost red.",
    "unlocked_by": "clue_003"
  },
  {
    "witness_id": "karl_metz_himself",
    "dialogue_key": "dlg_karl_001",
    "clue_revealed": "I was walking home. I heard something. I ran. I didn't see anything, I swear it.",
    "unlocked_by": null
  },
  {
    "witness_id": "karl_metz_himself",
    "dialogue_key": "dlg_karl_002",
    "clue_revealed": "His hands are trembling. There are scratches on his knuckles he keeps hiding in his sleeves. He knows what he is. He's trying to hold it together.",
    "unlocked_by": "clue_002"
  }
],

"grimm_diary_entry": "Blutbad — Bloodbath. The wolf-kin. Reformed ones restrain themselves through rigid routine and avoidance of triggers — raw meat, the scent of prey-Wesen, the full moon. When they slip, the frenzy is total. They remember nothing. The kill is always disproportionate — the Blutbad does not stop at death, it continues until spent or interrupted. Claw span is the surest physical identifier. A Blutbad's musk is distinctive: wet fur, iron, and something older underneath. Approach cautiously. A lucid Blutbad who knows what it has done may be more dangerous than one still in frenzy. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Karl Metz",
  "wesen_type": "Blutbad",
  "motive": "No conscious motive — the frenzy was triggered by Willem's Bauerschwein scent on the forest path. Ancient prey-predator instinct. Karl is horrified by what he's done.",
  "alibi": "Claims he went straight home from the inn. His wife confirms it — but she's covering for him and cracks when shown the coat fabric.",
  "alibi_breaks_on": "clue_005 — the coat fabric matches Karl's coat, which has a matching tear when inspected",
  "location": "His farmhouse, barely sleeping, barely holding himself together"
},

"red_herrings": [
  {
    "name": "Heinrich Vogel",
    "wesen_type": "Jägerbar (Bear)",
    "motive": "Old grudge — Willem underbid him on three contracts in a row.",
    "alibi": "Was at a lodge meeting — but it broke up at 9pm, leaving a window.",
    "why_suspicious": "Bear Wesen, physical strength, credible motive, window in alibi. The coat fabric could be his coloring."
  },
  {
    "name": "Oskar the Miller",
    "wesen_type": "Human (Kehrseite)",
    "motive": "The contract dispute — Willem had cost him significantly.",
    "alibi": "Was at home with his family — unverifiable.",
    "why_suspicious": "The threatening note exists. He has clear financial motive. He's not Wesen but the player doesn't know that yet."
  }
],

"community_npcs": [
  { "name": "Berta Metz", "wesen_type": "Seelengut", "role": "Karl's wife — covering for him out of fear and love" },
  { "name": "Rosa", "wesen_type": "Mauzhertz", "role": "Child witness — saw Karl enter the trees" }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Karl Metz",
  "required_clues": ["clue_001", "clue_002", "clue_005"],
  "response_dialogue": "Karl doesn't deny it when you finally say the word. He sits down on the stone step of his farmhouse and puts his head in his hands. 'I know,' he says. 'I've known since I woke up with blood on my boots.' He looks up. His eyes are red at the edges — not fully back yet. 'I didn't want to hurt anyone. I haven't slipped in eight years.' Then something shifts. His jaw sets. 'I'm not going back in a cage.' He stands."
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Heinrich Vogel",
    "dialogue": "Heinrich laughs — a short bark. 'You think a Jägerbar did that? Look at those wounds. That's not a bear swipe, that's a wolf rake. You're reading the wrong signs, Grimm.' He crosses his arms. 'I was at lodge. Check the register. I'll wait.'",
    "consequence": "Heinrich becomes an ally — he'll point the player toward Blutbad signs specifically, narrowing the field."
  },
  {
    "suspect_name": "Oskar the Miller",
    "dialogue": "Oskar goes white. 'I'm just a man! A regular man! I don't — what are you?' He backs away. 'I threatened him, yes, but with lawyers, not — whatever did that.'",
    "consequence": "Oskar now knows Grimms exist — minor complication, no mechanical impact."
  }
]
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "standard",
"hp": 50,
"woged_description": "Karl's face elongates, jaw pushing forward, teeth crowding. His eyes go full red — no whites at all. The coat tears across the shoulders as his posture shifts. He's large, hunched, still wearing his farmer's clothes underneath the woge. He smells like blood and wet earth.",

"arena_location": "The farmhouse yard. Open but enclosed by a low stone wall. A woodpile on one side, a water trough on the other.",

"attack_patterns": [
  {
    "name": "Claw swipe",
    "damage": 16,
    "type": "melee",
    "counter": "parry",
    "description": "Single wide swipe. Yellow-eye tell. Parry window is generous — this is the tutorial fight."
  },
  {
    "name": "Lunge grab",
    "damage": 20,
    "type": "melee",
    "counter": "dodge",
    "description": "He lunges and grabs — if it connects, a grapple animation plays and player takes tick damage for 2 seconds. Dodge sideways to avoid."
  },
  {
    "name": "Howl stagger",
    "damage": 8,
    "type": "aoe",
    "counter": "block",
    "description": "Short-range howl that staggers the player backward. Block to reduce stagger distance. Used to create space before a lunge."
  }
],

"phases": 1,
"weakness": null,
"prep_item": null,
"combat_notes": "Designed as the game's introductory combat encounter — generous tells, single phase, clear counter patterns. Karl can also be spared if the player has enough evidence and chooses the mercy dialogue option at HP < 15."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Karl Metz is dead in his own farmyard. His wife finds him at dawn. She doesn't ask how. She already knew this was coming — she's been waiting for it for eight years. You leave before she comes out. The village will call it a wild animal attack. They're not entirely wrong.",
  "killer_spared": "Karl Metz sits against the stone wall of his farmyard, breathing hard. You tell him what you know and what you could do. He nods. He's going to leave — tonight, before his wife wakes up. He'll find a Wieder Blutbad community, the reformed ones. Maybe that holds. Maybe it doesn't. You watch him go. The village will wonder where he went. Better that than the alternative.",
  "killer_escaped": "He cleared the stone wall before you could follow. Fast when he needs to be. The village will hear about it eventually — a Blutbad loose is a Blutbad that will slip again.",
  "wrong_accusation_closed": "The case closes cold. The village buries Willem Roth and calls it a wolf. Next winter it happens again."
},

"outcome_states": [
  { "state": "killer_defeated", "text": "Willem Roth avenged.", "reward": "30 gold, Blutbad diary entry, +1 village reputation" },
  { "state": "killer_spared", "text": "Karl Metz — gone. Watching.", "reward": "20 gold, Blutbad diary entry, Karl flagged as possible future ally" },
  { "state": "killer_escaped", "text": "Blutbad — at large.", "reward": "10 gold, Karl flagged as recurring threat" },
  { "state": "wrong_accusation_closed", "text": "Case unsatisfied.", "reward": "0 gold, reputation loss" }
],

"rewards": { "xp": 80, "items": [], "diary_entry_unlocked": "Blutbad" },
"unlocks": ["case_005"],
"arc_thread": "forest_road_killings"
```

---

# Case 005 — "The Patient Dark"
**Killer Wesen:** Lausenschlange | **Chapter:** 1 | **
### Recurring characters seeded
- Isolde Varn (Spinnetod, 003) — escaped state seeds her return
- Karl Metz (Blutbad, 004) — spared state seeds reformed Blutbad ally
- Marta Vaal (Hexenbiest, 006) — stripped state seeds possible future ally
- Sebastien Moor (Cracher-Mortel, 010) — escaped state seeds return
- Vesper (Gevatter Tod, 012) — escaped state, leaves note, professional respect thread
- Aldous Senn (Loewen, 012) — employer, potential Verrat node for later arc

---

*Case file batch v1.0 - Grimm Chronicles cases 004-012*
*For Godot agent import - each case self-contained, arc threads link across files*
