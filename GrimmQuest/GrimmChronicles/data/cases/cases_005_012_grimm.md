# Grimm Chronicles — Cases 005–012
*Continuation batch — for Godot agent import*

---

# Case 005 — "The Patient Dark"
**Killer Wesen:** Lausenschlange | **Chapter:** 1 | **Difficulty:** Easy-Medium

## META
```json
"case_id": "case_005",
"case_title": "The Patient Dark",
"chapter": 1,
"difficulty": "easy-medium",
"killer_wesen": "Lausenschlange",
"fairy_tale_hook": "The Snake in the Grass — patience as a weapon"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A cellar beneath a wine merchant's storehouse. Victim found between two large oak barrels. No signs of struggle anywhere.",

"victim": {
  "name": "Petra Holz",
  "wesen_type": "Mauzhertz (Mouse)",
  "occupation": "Bookkeeper, age 28",
  "condition": "No external wounds. Body contorted — spine curved, ribs compressed inward. Expression peaceful, eyes closed. She looks like she simply fell asleep between the barrels."
},

"opening_description": "Petra Holz was meticulous. Her ledgers were perfect, her figures never wrong, her cellar always locked. She had the only key. So whoever was in here with her either had a copy — or had been waiting in the dark long before she came down. There is no sign of struggle. No broken bottles, no overturned stools. Just a woman folded gently into the space between two barrels, her ribs pressed inward like a wrapped parcel.",

"time_of_death": "Between 6pm and 8pm",
"environmental_hazard": "Very low ceiling in cellar — combat movement limited, no room to dodge vertically"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Compression fractures on every rib — but no bruising on the skin. Force was distributed evenly, applied slowly and with sustained pressure rather than impact.",
    "points_to": "Lausenschlange",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "Faint parallel tracks in the dust on the floor — a sinuous trail leading from the large drainage gap in the far wall to the barrels. About 40cm wide.",
    "points_to": "Lausenschlange",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "The drainage gap in the wall has been widened recently — mortar scraped away from the edges. Something large passed through it.",
    "points_to": "Lausenschlange",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A shed scale — translucent, about 3cm, faintly iridescent — found caught on the barrel hoop. Not from any fish kept in this building.",
    "points_to": "Lausenschlange",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "Petra's ledger has a discrepancy flagged for today — a large sum that didn't balance. She had written 'ask Felix' in the margin.",
    "points_to": "red_herring_suspect_1",
    "found_by_default": true
  },
  {
    "clue_id": "clue_006",
    "description": "The cellar key was found in Petra's pocket — but a wax impression of it was found in a desk drawer in the office above.",
    "points_to": "red_herring_suspect_2",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "wine_merchant_boss",
    "dialogue_key": "dlg_boss_001",
    "clue_revealed": "Petra told me last week she'd found something in the accounts she couldn't explain. I told her to leave it alone.",
    "unlocked_by": null
  },
  {
    "witness_id": "delivery_boy",
    "dialogue_key": "dlg_delivery_001",
    "clue_revealed": "I saw someone near the back of the building around five. Big, kind of low to the ground. Moved strange. I thought maybe they were drunk.",
    "unlocked_by": null
  },
  {
    "witness_id": "wesen_informant",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "There's a Lausenschlange been in this quarter for months. They hunt Mauzhertz — old instinct. If one was in that cellar it was waiting long before Petra came down.",
    "unlocked_by": "clue_004"
  }
],

"grimm_diary_entry": "Lausenschlange — the louse snake. A boa-kin. They do not chase. They wait in darkness where their prey will come, and they are patient beyond what patience should mean in a living thing. The kill is constriction — ribs first, then the rest. No external marks. Bodies are often found looking peaceful because the prey loses consciousness before the damage is lethal. They have an ancient appetite for rodent-kin Wesen. In woge they are large and slow to turn but their grip, once applied, cannot be broken without a blade. The spine and skull are weak points. They shed periodically — find the scale and you find them. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Rudolf Schain",
  "wesen_type": "Lausenschlange",
  "motive": "Petra had found his embezzlement. He is also a Lausenschlange encountering a Mauzhertz — old prey instinct activated.",
  "alibi": "Claims he was at a suppliers' meeting upstairs all evening — three colleagues confirm.",
  "alibi_breaks_on": "clue_006 — the wax key impression is in his desk drawer",
  "location": "His office directly above the cellar"
},

"red_herrings": [
  {
    "name": "Felix Haas",
    "wesen_type": "Fuchsbau",
    "motive": "The ledger margin note — Petra was going to ask him about the discrepancy he'd buried.",
    "alibi": "Left the building at 4pm — two witnesses.",
    "why_suspicious": "His name is literally in the victim's notes."
  },
  {
    "name": "Anna Drescher",
    "wesen_type": "Human",
    "motive": "Petra reported her for petty theft three months ago. Anna lost her position.",
    "alibi": "Home alone — unverifiable.",
    "why_suspicious": "Known grievance. No alibi."
  }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Rudolf Schain",
  "required_clues": ["clue_001", "clue_004", "clue_006"],
  "response_dialogue": "Rudolf is very still when you say his name. Then he straightens and something behind his eyes goes flat. 'She was going to ruin me. Everything I built. Over numbers.' He tilts his head slightly — too far, wrong direction. 'I didn't plan it. I was simply there, and she came down, and...' He stands up. His spine starts to do something it shouldn't."
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Felix Haas",
    "dialogue": "Felix goes pale. 'The discrepancy was mine — but I was trying to fix it quietly. I didn't kill her. Check when I left.' He cooperates — reveals the wax impression location to clear himself.",
    "consequence": "Felix reveals clue_006 location."
  },
  {
    "suspect_name": "Anna Drescher",
    "dialogue": "Anna is calm. 'I hated her. But I'm not an animal. Look at what was done to her and tell me I did that.'",
    "consequence": "No mechanical consequence."
  }
]
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "environmental",
"hp": 60,
"woged_description": "Rudolf's neck extends first — then his torso, spine elongating beyond what a spine should do. His arms press to his sides as his legs fuse. He is suddenly very large in the low-ceilinged office.",
"arena_location": "Rudolf's office. Low ceiling, heavy furniture, very little floor space. A large desk in the centre.",
"attack_patterns": [
  { "name": "Constrict", "damage": 20, "type": "melee", "counter": "dodge", "description": "Wraps around the player on contact — grapple state, 8 damage/sec for 3 seconds. Press K to break grip." },
  { "name": "Body slam", "damage": 18, "type": "melee", "counter": "parry", "description": "Swings upper body sideways. Parryable on wind-up." },
  { "name": "Furniture sweep", "damage": 12, "type": "aoe", "counter": "dodge", "description": "Tail sweeps the desk across the room." }
],
"phases": 1,
"weakness": null,
"prep_item": null,
"combat_notes": "Introduces the grapple-break mechanic (K press). Low ceiling prevents vertical movement — deliberately cramped."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Rudolf Schain is dead in his office. You spend an hour on his ledgers afterward. The embezzlement goes back four years. You leave the books open on the merchant's desk with a note.",
  "killer_escaped": "The window was open. In his woged form he moved faster than expected. You find his shed skin on the sill. Petra Holz remains unavenged.",
  "wrong_accusation_closed": "Case closed cold. The accounts discrepancy is quietly absorbed."
},
"outcome_states": [
  { "state": "killer_defeated", "text": "Petra Holz avenged. Embezzlement exposed.", "reward": "40 gold, Lausenschlange diary entry" },
  { "state": "killer_escaped", "text": "Rudolf Schain at large.", "reward": "15 gold" }
],
"rewards": { "xp": 100, "items": ["Lausenschlange scale — crafting ingredient"], "diary_entry_unlocked": "Lausenschlange" },
"unlocks": ["case_006"],
"arc_thread": "merchant_quarter_killings"
```

---

# Case 006 — "The Glass Coffin"
**Killer Wesen:** Hexenbiest | **Chapter:** 1 | **Difficulty:** Medium-Hard

## META
```json
"case_id": "case_006",
"case_title": "The Glass Coffin",
"chapter": 1,
"difficulty": "medium-hard",
"killer_wesen": "Hexenbiest",
"fairy_tale_hook": "Snow White — the beautiful woman who brings death in a beautiful package"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A nobleman's manor. Victim found in his private study, seated at his desk. Candles burned to stubs. Quill still in hand.",

"victim": {
  "name": "Lord Aldric Fenn",
  "wesen_type": "Steinadler (Eagle) — Verrat informant",
  "occupation": "Nobleman and regional magistrate, age 55",
  "condition": "No wounds. No struggle. Glass of wine half-drunk. Expression of peace. Body cold far beyond what the time of death allows — the room is warm but he is ice-cold to the touch."
},

"opening_description": "Lord Aldric Fenn was a careful man with careful enemies. He spent thirty years collecting secrets and trading them carefully. Men like that don't die peacefully at their desks — unless someone made sure of it. His face is serene. His body is cold as river stone. The wine smells of nothing wrong. And yet.",

"time_of_death": "Between 8pm and 10pm",
"environmental_hazard": "Manor has multiple rooms — hexed objects possible if Grimm lingers too long"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "The body is abnormally cold — well beyond what time of death and a warm room can explain. Internal temperature suggests frozen from within.",
    "points_to": "Hexenbiest",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "A faint smell of burnt copper in the air — not from the candles. Something else was combusted in this room recently.",
    "points_to": "Hexenbiest",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "Small dark U-shaped mark found under the victim's tongue — looks like a birthmark. The biest mark.",
    "points_to": "Hexenbiest",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A half-written letter on the desk addressed to 'V.' It reads: 'She has been asking questions about the eastern routes. I believe she is —' The sentence ends there.",
    "points_to": "Hexenbiest",
    "found_by_default": true
  },
  {
    "clue_id": "clue_005",
    "description": "A woman's glove found behind the bookcase — fine leather, grey, very small. Monogrammed 'M.V.'",
    "points_to": "Hexenbiest",
    "found_by_default": false
  },
  {
    "clue_id": "clue_006",
    "description": "The butler reports a dispute between Lord Fenn and his nephew over the estate inheritance three weeks prior. Public threats were made.",
    "points_to": "red_herring_suspect_1",
    "found_by_default": true
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "butler",
    "dialogue_key": "dlg_butler_001",
    "clue_revealed": "A woman came to dinner last week. Beautiful. Dark hair. Lord Fenn turned away his last appointment for her. He seemed captivated afterward — distracted, almost dreamy.",
    "unlocked_by": null
  },
  {
    "witness_id": "butler",
    "dialogue_key": "dlg_butler_002",
    "clue_revealed": "When I passed back her wrap, I touched her hand. It was cold. Unnaturally cold. I thought I'd imagined it.",
    "unlocked_by": "clue_003"
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "M.V. — Marta Vaal. Verrat operative. A Hexenbiest. If Fenn was about to expose her, she'd have been sent to close him.",
    "unlocked_by": "clue_005"
  }
],

"grimm_diary_entry": "Hexenbiest — Witch-Beast. The most unpredictable Wesen I have encountered. Their kills leave no physical trace unless you know what to look for: the unnatural cold, the burnt-copper smell of Zaubertrank, and the biest mark under the tongue — always present in living and dead Hexenbiester. They are near-Grimm strength AND possess telekinesis, fire, and compulsion. Their only reliable weakness: Grimm blood causes immediate and permanent power loss. A Hexenbiest who has ingested Grimm blood becomes fully human. This does not make them less dangerous in the moment. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Marta Vaal",
  "wesen_type": "Hexenbiest",
  "motive": "Verrat operative — Fenn was about to expose her in a letter. She was sent to silence him.",
  "alibi": "Was at the theatre all evening — ticket stub, usher confirms.",
  "alibi_breaks_on": "clue_005 — the monogrammed glove. The usher is also Verrat and breaks when the glove is produced.",
  "location": "Her townhouse in the noble quarter — already preparing to leave"
},

"red_herrings": [
  {
    "name": "Nephew Caspar Fenn",
    "wesen_type": "Human",
    "motive": "Estate inheritance — stood to gain everything.",
    "alibi": "At his club all evening — six members confirm.",
    "why_suspicious": "Clear financial motive, public threat, stood to gain directly."
  },
  {
    "name": "Secretary Brennan",
    "wesen_type": "Steinadler",
    "motive": "Passed over for promotion twice. Access to the study.",
    "alibi": "Left the building at 7pm — gate log confirms.",
    "why_suspicious": "The half-written letter could implicate him as 'V.' — but he was trying to warn someone about Marta, not threaten Fenn."
  }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Marta Vaal",
  "required_clues": ["clue_001", "clue_003", "clue_005"],
  "response_dialogue": "Marta looks at you for a long moment, then smiles — and something in that smile is very old and very tired. 'A Grimm. How inconvenient.' Her hair goes white at the roots. Her skin does what skin shouldn't. Objects around the room begin to drift slightly off their surfaces."
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Caspar Fenn",
    "dialogue": "Caspar's outrage is genuine and loud. Six witnesses, a club register, and his lawyers in under an hour.",
    "consequence": "Time pressure — legal obstacle appears. Limited moves before officials complicate the case."
  },
  {
    "suspect_name": "Secretary Brennan",
    "dialogue": "Brennan is composed. He explains the letter — 'V' is Vaal. He was trying to warn someone about Marta. He provides her name directly.",
    "consequence": "Wrong accusation accidentally accelerates the correct path."
  }
]
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "standard",
"hp": 65,
"woged_description": "Marta's hair is white and wild. Skin grey and cracked, eyes dark hollows, teeth lengthened. Still beautiful in a way that is purely terrifying. Objects in the room orbit her slowly.",
"arena_location": "The manor entry hall — high ceiling, chandelier overhead, wide staircase. Objects available as projectiles.",
"attack_patterns": [
  { "name": "Telekinetic throw", "damage": 14, "type": "ranged", "counter": "dodge", "description": "Hurls furniture. Telegraphed by object rising." },
  { "name": "Fire lash", "damage": 20, "type": "melee", "counter": "parry", "description": "Whip of fire. Parryable on yellow-eye tell." },
  { "name": "Compulsion pulse", "damage": 10, "type": "aoe", "counter": "block", "description": "Controls invert for 2 seconds if not blocked." },
  { "name": "Cold touch", "damage": 25, "type": "melee", "counter": "dodge", "description": "Phase 2 only. Direct contact — same cold that killed Fenn. Cannot be blocked or parried." }
],
"phases": 2,
"phase_2_trigger": "HP drops below 30",
"phase_2_change": "Cold touch introduced. Telekinetic throws become multi-object salvos.",
"weakness": "Grimm blood — if player takes any hit early, a close-range 'blood strike' prompt appears. Strips Marta of all powers permanently and ends the fight immediately.",
"prep_item": null
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Marta Vaal is dead on the manor floor, human again at the end. The half-written letter goes to someone who might use it. The Verrat lost an operative tonight. They'll send another.",
  "killer_stripped": "Marta Vaal is human. She stands looking at her own hands and says nothing for a long moment. Then: 'I've been that for forty years. I'd forgotten what this felt like.' She doesn't run.",
  "killer_escaped": "She went through a second-floor window. Flying — you didn't know they could do that. The Verrat now knows a Grimm is working this quarter.",
  "wrong_accusation_closed": "Case closed cold. Fenn's letter was never sent. The eastern route remains secret."
},
"outcome_states": [
  { "state": "killer_defeated", "text": "Fenn avenged. Verrat operative eliminated.", "reward": "60 gold, Hexenbiest diary entry, Verrat faction -1 awareness" },
  { "state": "killer_stripped", "text": "Marta Vaal — human. Fate unknown.", "reward": "40 gold, diary entry, Marta flagged as possible future ally" },
  { "state": "killer_escaped", "text": "Hexenbiest at large. Verrat alerted.", "reward": "10 gold, Verrat faction +1 awareness" }
],
"rewards": { "xp": 140, "items": ["Hexenbiest hair — crafting ingredient", "Verrat cipher fragment — arc item"], "diary_entry_unlocked": "Hexenbiest" },
"unlocks": ["case_007"],
"arc_thread": "verrat_conspiracy"
```

---

# Case 007 — "The Red Feast"
**Killer Wesen:** Skalenzähne | **Chapter:** 2 | **Difficulty:** Medium

## META
```json
"case_id": "case_007",
"case_title": "The Red Feast",
"chapter": 2,
"difficulty": "medium",
"killer_wesen": "Skalenzahne",
"fairy_tale_hook": "Hansel and Gretel — something that eats, and cannot stop"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A butcher's backroom, after hours. Blood everywhere — far more than the victim could account for. Cuts of meat still hanging on hooks.",

"victim": {
  "name": "Bruno Stark",
  "wesen_type": "Seelengut (Sheep)",
  "occupation": "Butcher's assistant, age 22",
  "condition": "Partially consumed. Bite wounds unlike any tool — enormous radius, serrated edges. One arm missing below the elbow. Two phases of wounds visible — controlled, then frenzied."
},

"opening_description": "Bruno Stark worked late. Tonight the back room tells a story of something that started as an attack and became something else. The bite marks are not consistent with any tool or animal kept in this town. And whatever made them came back for more — the wounds are not all from the same moment. Bruno was alive for some of this.",

"time_of_death": "Between 9pm and 11pm",
"environmental_hazard": "Meat hooks overhead — environmental weapon and movement obstacle"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Bite radius is 34cm — consistent with a large crocodilian. Serrated tooth impressions in bone. No animal matching this profile exists in this region.",
    "points_to": "Skalenzahne",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "Two distinct attack phases — controlled initial wounds, then frenzied feeding marks. The frenzy was triggered, not planned.",
    "points_to": "Skalenzahne",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "Dried blood on the delivery entrance handle — the attacker left and came back. Two sets of tracks.",
    "points_to": "Skalenzahne",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A scute — a bony plate, 4cm, greenish-grey — found under the workbench. Not from any livestock.",
    "points_to": "Skalenzahne",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "Bruno had caught someone stealing from the till two nights ago and reported it. The dismissed worker has a violent record.",
    "points_to": "red_herring_suspect_1",
    "found_by_default": true
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "neighbour",
    "dialogue_key": "dlg_neighbour_001",
    "clue_revealed": "I heard something wet in the alley around ten. Then quiet. Then movement again around eleven.",
    "unlocked_by": "clue_003"
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "New man at the tannery — Heinrich Kroll. Wide jaw, keeps to himself. Been here six weeks. Right around when the stray cats started disappearing.",
    "unlocked_by": "clue_004"
  }
],

"grimm_diary_entry": "Skalenzahne — Scale-Tooth. A crocodile-kin. They live peacefully among humans until they taste human or Wesen flesh. The first taste triggers an addiction that is near-impossible to break — the flesh hunger overrides all other drives. The two-phase attack (controlled strike, then feeding frenzy) indicates the tasting was accidental and the frenzy was triggered by the blood. Thick hide — standard weapons deal reduced damage. Aim for the underbelly. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Heinrich Kroll",
  "wesen_type": "Skalenzahne",
  "motive": "Accidental first taste — Bruno cut himself on a hook and bled during a delivery. Heinrich left, fought it, lost, came back.",
  "alibi": "At the tannery all night — foreman confirms loosely.",
  "alibi_breaks_on": "clue_003 + clue_004 — two sets of tracks and the scute at the scene",
  "location": "His lodgings near the tannery — barely in control"
},

"red_herrings": [
  {
    "name": "Thomas Grau",
    "wesen_type": "Drang-Zorn (Badger)",
    "motive": "Dismissed for theft, publicly blamed by Bruno.",
    "alibi": "Drinking at the tavern — left at 9:30pm with a gap before he got home.",
    "why_suspicious": "Motive, capable of violence, gap in alibi. Berserker episodes he doesn't remember make him look very guilty."
  }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Heinrich Kroll",
  "required_clues": ["clue_001", "clue_002", "clue_004"],
  "response_dialogue": "Heinrich opens his door and you see it immediately — the jaw sits fractionally too wide. He knows you see it. 'I tried to stop,' he says. 'I went home. I walked five miles in the cold.' His hands are shaking. 'I thought I had it.' He swallows. 'But I could smell it from the street.'"
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Thomas Grau",
    "dialogue": "Thomas is drunk but not stupid. He holds up his hands — no blood, small fingers. 'Find someone with a bigger mouth than me.' He drunkenly mentions Heinrich's wide jaw.",
    "consequence": "Wrong accusation accidentally surfaces Heinrich as a person of interest."
  }
]
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "standard",
"hp": 70,
"woged_description": "Heinrich's jaw unhinges to an impossible width, rows of serrated teeth exposed. Skin ripples into scutes. He drops to a lower, wider stance — moving in fast lateral scuttles.",
"arena_location": "The tannery floor — long narrow space, raw hides hanging, large vats of fluid.",
"attack_patterns": [
  { "name": "Bite lunge", "damage": 28, "type": "melee", "counter": "dodge", "description": "Explosive forward lunge, narrow horizontal spread. Huge damage. Dodge sideways." },
  { "name": "Tail sweep", "damage": 12, "type": "aoe", "counter": "dodge", "description": "Low tail sweep at ankle height. Jump or dodge back." },
  { "name": "Hide charge", "damage": 18, "type": "melee", "counter": "parry", "description": "Shoulder-first charge. Parry opens him up for a counter." }
],
"phases": 2,
"phase_2_trigger": "HP drops below 35",
"phase_2_change": "Bite lunge frequency doubles. Uses the vats — shoves player toward them.",
"weakness": "Underbelly — attacks during bite lunge recovery deal double damage."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Heinrich Kroll is dead on the tannery floor. You don't feel certain about this one. He told you he tried to stop. That was probably even true.",
  "killer_escaped": "He went through the tannery wall. The flesh hunger doesn't feel pain the way a resting Skalenzahne does.",
  "wrong_accusation_closed": "Case closed cold. The stray cats are still disappearing."
},
"rewards": { "xp": 120, "items": ["Skalenzahne scute — crafting ingredient"], "diary_entry_unlocked": "Skalenzahne" },
"unlocks": ["case_008"],
"arc_thread": null
```

---

# Case 008 — "The Beautiful Shepherd"
**Killer Wesen:** Ziegevolk | **Chapter:** 2 | **Difficulty:** Medium

## META
```json
"case_id": "case_008",
"case_title": "The Beautiful Shepherd",
"chapter": 2,
"difficulty": "medium",
"killer_wesen": "Ziegevolk",
"fairy_tale_hook": "Bluebeard — a charming man with a locked room full of secrets"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A prosperous farm on the edge of town. Three women have gone missing over two months. No bodies. Families are desperate.",

"victim": {
  "name": "Hilde Braun, Clara Voss, Marta Engel",
  "wesen_type": "Seelengut, Human, Fuchsbau",
  "occupation": "All unmarried women, ages 20-30, all last seen near the market",
  "condition": "No bodies. All last seen smiling, following a charming man. All described the same man independently."
},

"opening_description": "There are no bodies. There are three empty chairs at three family tables and three women who walked away smiling and never came back. No signs of struggle. They simply went, willingly, following a man nobody can fully describe except to say he was charming. That is not a natural happiness.",

"time_of_death": "N/A — missing persons case",
"environmental_hazard": "Farmhouse has a locked cellar — the women are there, willingly"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "All three women were last seen in the same two-block area near the spice stall. All described feeling immediately calm and happy after passing it.",
    "points_to": "Ziegevolk",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "A faint musky-sweet smell near the spice stall that vendors noticed — not any spice they sell. Present on warm days only.",
    "points_to": "Ziegevolk",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "All three women made unexplained withdrawals from family savings in the days before disappearing — moderate sums, freely given.",
    "points_to": "Ziegevolk",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A neighbour describes seeing the women led past his window — not dragged, not forced, but moving like sleepwalkers. Smiling.",
    "points_to": "Ziegevolk",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "The spice stall is rented by a man named Aldric Haen. He also owns a farm three miles out. Described by everyone as extraordinarily handsome.",
    "points_to": "Ziegevolk",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "market_vendor",
    "dialogue_key": "dlg_vendor_001",
    "clue_revealed": "The smell was strongest when Aldric was working. I always felt good around him. We all did. I never thought that was strange until now.",
    "unlocked_by": "clue_002"
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "Ziegevolk. Goat-kin. They don't kill — they collect. Pheromone control. The women are alive on his farm. They just don't want to leave.",
    "unlocked_by": "clue_002"
  },
  {
    "witness_id": "rescued_woman",
    "dialogue_key": "dlg_rescued_001",
    "clue_revealed": "Even now, two days later, I still want to go back. That's the terrifying part.",
    "unlocked_by": "clue_005"
  }
],

"grimm_diary_entry": "Ziegevolk — Goat-Folk. No physical threat. Their power is entirely pheromonal — complete emotional compliance in anyone exposed. Victims are not confused; they are happy. They follow willingly. A Grimm is not fully immune — extended exposure dulls the senses and creates compliance. Cover the nose. Move fast. The Ziegevolk itself is physically weak. Reach it before the pheromones do their work. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Aldric Haen",
  "wesen_type": "Ziegevolk",
  "motive": "Compulsive collecting — forms harems of compliant people, takes their money and labour. They believe they are happy.",
  "alibi": "Nobody who has been near him long enough wants to report him.",
  "alibi_breaks_on": "clue_005 — farm location plus wesen_contact testimony",
  "location": "His farm — the women are in the locked cellar, willingly"
},

"red_herrings": [
  {
    "name": "Former suitor Dieter",
    "wesen_type": "Reinigen",
    "motive": "Rejected and aggressive.",
    "alibi": "Drinking publicly when the last disappearance occurred — witnessed.",
    "why_suspicious": "Classic profile. The family pointed at him specifically."
  }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Aldric Haen",
  "required_clues": ["clue_001", "clue_002", "clue_005"],
  "response_dialogue": "Aldric opens the door and smiles, and for a moment — just a moment — you understand exactly why three women followed him. Then you identify what you're feeling, name it, and step back. His smile doesn't change. 'You're a Grimm,' he says pleasantly. 'The pheromones don't work as well on you, do they. How disappointing.'"
}
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "environmental",
"hp": 28,
"woged_description": "Small curved horns, pupils going rectangular, a faint shimmer on the skin. He is not physically impressive. That is the point.",
"arena_location": "The farmhouse yard. The three women are present — they will intervene to protect him.",
"attack_patterns": [
  { "name": "Pheromone burst", "damage": 0, "type": "special", "counter": "block", "description": "Controls invert for 3 seconds if not blocked. The primary danger." },
  { "name": "Compelled shield", "damage": 0, "type": "special", "counter": "none", "description": "A woman steps between Aldric and the player. Talk her down with dialogue prompt or maneuver around." },
  { "name": "Desperate strike", "damage": 10, "type": "melee", "counter": "parry", "description": "His only direct attack. Easily parried." }
],
"phases": 1,
"combat_notes": "Puzzle-combat hybrid. Player must clear the three women from pheromone range first — without them as shields, Aldric is trivially easy. The real challenge is the environmental puzzle."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Aldric Haen is dead. The three women stand in the yard and the haze lifts slowly. Marta the Fuchsbau understands perfectly and is furious at herself. You help them back to town. It takes two days before they stop asking if you're sure.",
  "killer_captured": "Aldric is bound. He will be charming the whole way to the cells. You warn the guards in writing.",
  "killer_escaped": "He ran when the pheromones failed. You find the women confused and cold in the yard, the compulsion dissolving. They are safe. He is not caught.",
  "wrong_accusation_closed": "The women remain on the farm, happy and fading."
},
"rewards": { "xp": 110, "items": ["Ziegevolk musk sample — crafting ingredient"], "diary_entry_unlocked": "Ziegevolk" },
"unlocks": ["case_009"],
"arc_thread": null
```

---

# Case 009 — "The Running Night"
**Killer Wesen:** Coyotl | **Chapter:** 2 | **Difficulty:** Medium

## META
```json
"case_id": "case_009",
"case_title": "The Running Night",
"chapter": 2,
"difficulty": "medium",
"killer_wesen": "Coyotl",
"fairy_tale_hook": "The Wild Hunt — a ritual the community believes is sacred and the outsider must interrupt"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A crossroads outside the town. A young woman found at dawn, wounds from multiple attackers.",

"victim": {
  "name": "Ingrid Farr",
  "wesen_type": "Human (Kehrseite)",
  "occupation": "Farmer's daughter, age 17",
  "condition": "Multiple lacerations from at least three separate attackers. She ran — wounds suggest pursuit over distance. She almost made it to the road."
},

"opening_description": "Ingrid Farr ran through the night and nearly made it. The crossroads are 200 metres from the main road. The wounds on her back outnumber the wounds on her front — she never stopped running. At least three sets of tracks follow her. Whatever hunted her did so as a group and knew the terrain better than she did.",

"time_of_death": "Between midnight and 3am",
"environmental_hazard": "Forest terrain at night for any chase or confrontation sequence"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Three distinct wound patterns from three attackers — claw geometry consistent with canine-kin. Coordinated — they flanked her.",
    "points_to": "Coyotl",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "A carved wooden token in the victim's hand — she grabbed it from one of her attackers. Carved with a crescent and claw motif.",
    "points_to": "Coyotl",
    "found_by_default": true
  },
  {
    "clue_id": "clue_003",
    "description": "The trail begins at an old standing stone two miles into the forest. Candle wax, ash, and a circle of disturbed earth. A ritual space used recently.",
    "points_to": "Coyotl",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "The token matches the Aseveracion — a Coyotl coming-of-age rite in which the young must hunt and kill a human before the new moon.",
    "points_to": "Coyotl",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "farmer_father",
    "dialogue_key": "dlg_father_001",
    "clue_revealed": "She said she'd been followed home from the well twice that week. By young men, she thought — but they moved strange.",
    "unlocked_by": null
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "The Aseveracion is a Coyotl rite of adulthood — hunt and kill before the new moon. The Farren family settled here three years ago. Three sons, oldest just turned seventeen.",
    "unlocked_by": "clue_004"
  },
  {
    "witness_id": "coyotl_mother",
    "dialogue_key": "dlg_mother_001",
    "clue_revealed": "She knows what her sons did. Terrified of you and of her own family's law. She'll protect them by instinct but she's not a killer. She can be reached.",
    "unlocked_by": "clue_002"
  }
],

"grimm_diary_entry": "Coyotl — the coyote-kin. Pack hunters with strong family clan structure. The Aseveracion is their most dangerous tradition — the young must complete a hunt before the new moon. Outside the ritual they are often peaceable family units. Interrupting or punishing the Aseveracion creates a blood feud with the entire clan. A Grimm must decide whether to pursue the killers or negotiate a cessation of the tradition. Both paths exist. Both have costs. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "The Farren brothers — Lukas (17), Rolf (20), Daan (23)",
  "wesen_type": "Coyotl",
  "motive": "The Aseveracion — Lukas completing his rite. Rolf and Daan running support. Father sanctioned it.",
  "alibi": "All claim they were home asleep. Mother confirms it — lying.",
  "alibi_breaks_on": "clue_003 + clue_004 — ritual site and token connect to the Farren family",
  "location": "The Farren farmhouse"
}
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Lukas Farren",
  "required_clues": ["clue_001", "clue_002", "clue_004"],
  "response_dialogue": "Lukas meets your eyes directly. 'It is our law,' he says. Not defiant — just stating a fact he was raised on. Behind him Rolf and Daan come to the door. 'She was chosen fairly. We followed the ritual.' He looks at you carefully. 'Are you here for blood or for understanding?'"
}
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "standard",
"hp": 55,
"woged_description": "Lukas is lean in woge — sandy fur, ears high, yellow eyes. Low quick dashes. Rolf and Daan flank if all three fight.",
"arena_location": "The farmhouse yard or the ritual site in the forest.",
"attack_patterns": [
  { "name": "Pack flank", "damage": 14, "type": "melee", "counter": "dodge", "description": "Two attackers from different angles simultaneously. Dodge toward one to collapse the angle." },
  { "name": "Dart bite", "damage": 16, "type": "melee", "counter": "parry", "description": "Fast forward snap. Parryable." },
  { "name": "Scatter", "damage": 0, "type": "special", "counter": "none", "description": "Brothers reposition — player must reorient. Creates openings for next attack." }
],
"phases": 1,
"combat_notes": "Negotiation path available — if the player has the mother's testimony and chooses the dialogue option at confrontation start, the brothers stand down. The Aseveracion ceases. Different rewards."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Lukas Farren is dead. His brothers are alive. They look at you with something that isn't grief and isn't hate — it's older than either.",
  "negotiated": "The Aseveracion ends with this generation. The father agrees through clenched teeth. Lukas gets five years' exile. You're not sure justice was served.",
  "killer_escaped": "All three cleared the fence. The clan is now aware of you.",
  "wrong_accusation_closed": "The Aseveracion continues. Next new moon, someone else runs."
},
"outcome_states": [
  { "state": "killer_defeated", "text": "Ingrid avenged. Tradition broken by blood.", "reward": "60 gold, Coyotl diary entry, Coyotl clan blood feud risk" },
  { "state": "negotiated", "text": "Aseveracion ended. Partially avenged.", "reward": "40 gold, Coyotl mother as future contact" }
],
"rewards": { "xp": 130, "items": ["Aseveracion token — lore item"], "diary_entry_unlocked": "Coyotl" },
"unlocks": ["case_010"],
"arc_thread": "ritual_killings"
```

---

# Case 010 — "Dead Men Walking"
**Killer Wesen:** Cracher-Mortel | **Chapter:** 2 | **Difficulty:** Hard

## META
```json
"case_id": "case_010",
"case_title": "Dead Men Walking",
"chapter": 2,
"difficulty": "hard",
"killer_wesen": "Cracher-Mortel",
"fairy_tale_hook": "Sleeping Beauty — death that isn't death, and waking that is worse"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A merchant buried three days ago has been seen walking through the lower quarter at night — by four separate witnesses. His grave is empty.",

"victim": {
  "name": "Conrad Weiss",
  "wesen_type": "Eisbiber (Beaver)",
  "occupation": "Cloth merchant, age 48",
  "condition": "Officially dead — buried three days ago. Now reportedly walking, vacant-eyed, running errands for someone. His family is terrified."
},

"opening_description": "Conrad Weiss died on a Tuesday. The physician certified it. The family buried him on Thursday. On Saturday night his neighbour saw him crossing the square carrying a bundle. This is not a resurrection. This is something considerably worse.",

"time_of_death": "N/A — Conrad is alive, enslaved by tetrodotoxin",
"environmental_hazard": "Cracher-Mortel's safehouse — confined, multiple rooms. Conrad present as potential second hostile."
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "The grave was opened from the outside — coffin lid shows scrape marks on the exterior, hinges bent outward.",
    "points_to": "Cracher-Mortel",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "Physician's death notes describe the collapse as sudden, painless, breathing undetectable. Classic tetrodotoxin presentation — induced suspended animation.",
    "points_to": "Cracher-Mortel",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "Conrad has been seen carrying stolen goods from three warehouses. He is being used as a thief.",
    "points_to": "Cracher-Mortel",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A distinctive blue-grey spittle residue on Conrad's collar from when he was 'killed.' Matches no known local plant or poison.",
    "points_to": "Cracher-Mortel",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "Conrad was seen entering the same building in the tannery district three times. He enters like he was told to.",
    "points_to": "Cracher-Mortel",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 4,

"witness_clues": [
  {
    "witness_id": "conrads_wife",
    "dialogue_key": "dlg_wife_001",
    "clue_revealed": "The week before he died, a stranger came asking about our warehouse schedule. Conrad turned him away. The next day Conrad collapsed.",
    "unlocked_by": null
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "Cracher-Mortel. Puffer fish kin. Their spit induces a trance that looks like death — the victim is conscious inside it. They get dug up, enslaved. The trance ends in stages: rage, then death. Conrad has days.",
    "unlocked_by": "clue_004"
  }
],

"grimm_diary_entry": "Cracher-Mortel — Dead Spit. Puffer-fish kin. Their saliva contains tetrodotoxin that induces complete physical paralysis while leaving the mind intact. The victim is aware of their own burial. After extraction, a second compound creates servile compulsion. The victim progresses through four stages over 7-10 days: suspended animation, compelled servitude, rage state, death. There is a reversal agent — it must be administered before the rage state begins. Find the victim before the fourth day. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Sebastien Moor",
  "wesen_type": "Cracher-Mortel",
  "motive": "Criminal operation — using enslaved victims to rob warehouses and eliminate competition.",
  "alibi": "Nobody has connected him to Conrad. His tannery building is the link.",
  "alibi_breaks_on": "clue_005 — the building is leased under a false name matching his description",
  "location": "The tannery district building — Conrad is there too"
}
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Sebastien Moor",
  "required_clues": ["clue_002", "clue_004", "clue_005", "clue_001"],
  "response_dialogue": "The door opens before you knock. Sebastien Moor sits at the table as if expecting you. Conrad stands in the corner stacking boxes. He doesn't turn. 'The Grimm,' Moor says. He gestures at Conrad. 'You can fight me or you can save him. You probably cannot do both.'"
}
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "environmental",
"hp": 58,
"woged_description": "Moor's cheeks distend, lips pull back from a wide flat mouth, skin mottled grey-blue. He keeps his distance — his weapon is the spit, not his hands.",
"arena_location": "The tannery building. Conrad is present — enters rage state if fight exceeds 3 minutes. Reversal agent visible on a shelf mid-fight.",
"attack_patterns": [
  { "name": "Tetrodotoxin spit", "damage": 0, "type": "ranged", "counter": "dodge", "description": "Controls invert for 5 seconds on contact. The core danger. No HP damage." },
  { "name": "Compulsion compound", "damage": 0, "type": "ranged", "counter": "block", "description": "Applied to Conrad — makes him attack the player. Block to resist Conrad." },
  { "name": "Defensive strike", "damage": 8, "type": "melee", "counter": "parry", "description": "Desperate close-range strike when cornered." }
],
"phases": 2,
"phase_2_trigger": "2.5 minutes elapsed without killing Moor",
"phase_2_change": "Conrad enters rage state — now hostile. Fight becomes two-on-one. Reversal agent resets Conrad.",
"combat_notes": "Timer and reversal agent are core mechanics. Prioritise Moor for harder fight, save Conrad. Grab the agent first to manage Conrad but give Moor time to stack spit attacks."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "conrad_saved_moor_dead": "Moor is dead. Conrad sits on the floor, the reversal agent working. He remembers everything — including being buried. When you help him home, his wife holds him in the doorway for a long time.",
  "conrad_saved_moor_escaped": "Moor ran when Conrad came back to himself. You chose correctly. But Moor is loose.",
  "moor_dead_conrad_lost": "Conrad entered rage state before you reached the agent. What you had to do will stay with you. The Eisbiber lodge will not forgive this easily.",
  "wrong_accusation_closed": "Conrad dies on day ten. His wife gets a second burial."
},
"outcome_states": [
  { "state": "conrad_saved_moor_dead", "text": "Conrad recovered. Moor eliminated.", "reward": "80 gold, Cracher-Mortel diary entry, +3 Eisbiber reputation" },
  { "state": "moor_dead_conrad_lost", "text": "Moor dead. Conrad lost.", "reward": "30 gold, -3 Eisbiber reputation" }
],
"rewards": { "xp": 180, "items": ["Cracher-Mortel toxin sample", "Reversal agent formula — crafting recipe unlocked"], "diary_entry_unlocked": "Cracher-Mortel" },
"unlocks": ["case_011"],
"arc_thread": "merchant_quarter_killings"
```

---

# Case 011 — "The Good Neighbour"
**Killer Wesen:** Klaustreich | **Chapter:** 2 | **Difficulty:** Easy-Medium

## META
```json
"case_id": "case_011",
"case_title": "The Good Neighbour",
"chapter": 2,
"difficulty": "easy-medium",
"killer_wesen": "Klaustreich",
"fairy_tale_hook": "Puss in Boots — charming, manipulative, dangerous behind the mask"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A narrow tenement lane in the poor quarter. A Reinigen man found dead at the base of a wall — four storeys below an open window.",

"victim": {
  "name": "Pieter Maus",
  "wesen_type": "Reinigen (Rat)",
  "occupation": "Tailor's cutter, age 31",
  "condition": "Fall injuries — but impact wounds don't match a straight fall. Claw lacerations on upper arms and shoulders, consistent with being grabbed from behind and thrown."
},

"opening_description": "Falls happen in the tenements. But Pieter Maus was careful and sober, and the railing was solid. The claw marks on his shoulders are the thing. Falls don't leave claw marks. Something had him first.",

"time_of_death": "Between 10pm and midnight",
"environmental_hazard": "Tenement building — vertical space, multiple floors, narrow stairwells"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Claw marks on upper arms and shoulders — grip-shaped, four points each hand, feline geometry. He was grabbed from behind and thrown.",
    "points_to": "Klaustreich",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "The window above is not Pieter's room — it belongs to the floor above, a man named Franz Keel who moved in six months ago.",
    "points_to": "Klaustreich",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "Cat hair — tabby-coloured, coarse, distinctly non-domestic in thickness — on the windowsill and on Pieter's collar.",
    "points_to": "Klaustreich",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "Three Reinigen neighbours report being harassed and threatened by Franz Keel since he moved in. None reported it formally out of fear.",
    "points_to": "Klaustreich",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 3,

"witness_clues": [
  {
    "witness_id": "reinigen_neighbour",
    "dialogue_key": "dlg_neighbour_001",
    "clue_revealed": "We avoid Keel. He looks at us like we're something to step on. Since he moved in, three families have quietly left.",
    "unlocked_by": null
  },
  {
    "witness_id": "landlady",
    "dialogue_key": "dlg_landlady_001",
    "clue_revealed": "Keel is charming with me. But I found scratch marks on his door frame that go up to seven feet.",
    "unlocked_by": "clue_003"
  },
  {
    "witness_id": "child_witness",
    "dialogue_key": "dlg_child_001",
    "clue_revealed": "I saw Mr Keel on the roof last week. He wasn't using the stairs. He came down the outside wall.",
    "unlocked_by": "clue_002"
  }
],

"grimm_diary_entry": "Klaustreich — Scratch Prankster. Alley-cat kin. Charming to those they consider worth charming, predatory toward those they consider beneath them. Reinigen are their traditional prey — hunted for sport with no moral weight. They leap from heights that would kill a human. Their claw geometry is distinctive — four-point grip, feline spacing. A Klaustreich who has decided to kill has already planned the exit. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Franz Keel",
  "wesen_type": "Klaustreich",
  "motive": "Ancient hatred of Reinigen. Pieter's presence was intolerable. He'd been driving Reinigen out and Pieter refused to leave.",
  "alibi": "Claims he was asleep.",
  "alibi_breaks_on": "clue_002 + clue_003 — his window, his cat hair on the victim",
  "location": "His room on the fourth floor"
}
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Franz Keel",
  "required_clues": ["clue_001", "clue_003", "clue_004"],
  "response_dialogue": "Franz leans against his door frame and looks at you with flat cat-assessment. 'The rat fell. Terrible accident.' He doesn't move. 'You can't prove otherwise.' But his eyes have gone to vertical slits."
}
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "environmental",
"hp": 42,
"woged_description": "Pupils go vertical, fingers elongate into hooked claws. He drops low and moves fluid and wrong — uses walls and ceiling as readily as the floor.",
"arena_location": "The tenement stairwell and fourth-floor landing — vertical space, tight corners.",
"attack_patterns": [
  { "name": "Wall launch", "damage": 18, "type": "melee", "counter": "parry", "description": "Launches off a wall for a horizontal strike. Wall-push gives a tell." },
  { "name": "Ceiling drop", "damage": 20, "type": "special", "counter": "dodge", "description": "Drops from ceiling directly above. Shadow tell. Dodge sideways." },
  { "name": "Claw rake", "damage": 14, "type": "melee", "counter": "dodge", "description": "Fast horizontal swipe at close range. Dodge back." }
],
"phases": 1,
"combat_notes": "Introduces vertical combat — Keel moves on walls and ceiling. Player must track him in 3D space."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "killer_defeated": "Franz Keel is dead on the fourth-floor landing. The Reinigen gather at the stairwell door within the hour. One woman leaves dried herbs on the step near where he fell.",
  "killer_escaped": "He went out the window and up the roof. The Reinigen lock their doors and wait.",
  "wrong_accusation_closed": "Franz Keel stays. The tenement empties around him."
},
"rewards": { "xp": 90, "items": ["Klaustreich claw — crafting ingredient"], "diary_entry_unlocked": "Klaustreich" },
"unlocks": ["case_012"],
"arc_thread": null
```

---

# Case 012 — "The Clean Hand"
**Killer Wesen:** Gevatter Tod | **Chapter:** 3 | **Difficulty:** Hard

## META
```json
"case_id": "case_012",
"case_title": "The Clean Hand",
"chapter": 3,
"difficulty": "hard",
"killer_wesen": "Gevatter Tod",
"fairy_tale_hook": "Godfather Death — a killer who serves something larger and always collects exactly what is owed"
```

## PHASE 1 — DISCOVERY
```json
"scene_location": "A guildhall meeting room. Four guild masters found dead at the table, as if in mid-conversation. No signs of struggle. Cups still in hands.",

"victim": {
  "name": "Four guild masters",
  "wesen_type": "Steinadler, Fuchsbau, Eisbiber, Human",
  "occupation": "Guild council — controlled trade licensing for the entire quarter",
  "condition": "All four dead in their seats. No wounds visible. Expressions neutral — not peaceful, not terrified. Simply stopped. Time of death identical for all four."
},

"opening_description": "Four men sat down to a meeting and never stood up. The cups are still in their hands. No poison in the cups, the physician says. No wounds. No evidence of anything except four men who simply stopped. Together. At the same moment. Someone did this deliberately, professionally, and left nothing behind except the fact that it was done.",

"time_of_death": "Exactly 9pm — a witness noted the guild lights still on at 9:00. Dark by 9:15.",
"environmental_hazard": "Guildhall has multiple exits — killer may have used any of them"
```

## PHASE 2 — EVIDENCE
```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "A microscopic puncture wound on the back of each victim's neck — consistent with a very fine hollow appendage. Near-invisible without magnification.",
    "points_to": "Gevatter Tod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_002",
    "description": "The toxin — finally identified after extensive analysis — is biological, not pharmaceutical. Produced by a living organism. Acts in under 60 seconds.",
    "points_to": "Gevatter Tod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_003",
    "description": "A single black wing-case fragment — 8mm, chitinous — found on the floor under the table. Not from any beetle native to this region.",
    "points_to": "Gevatter Tod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "The guild masters were scheduled to vote on a trade route reassignment tomorrow — a decision that would have ruined a specific consortium. The meeting was not public knowledge.",
    "points_to": "Gevatter Tod (hired context)",
    "found_by_default": true
  },
  {
    "clue_id": "clue_005",
    "description": "A service entrance log shows a 'maintenance worker' entered at 8:45pm and signed out at 9:05pm. Signature illegible. Description deliberately generic.",
    "points_to": "Gevatter Tod",
    "found_by_default": false
  }
],
"min_clues_to_accuse": 4,

"witness_clues": [
  {
    "witness_id": "hall_servant",
    "dialogue_key": "dlg_servant_001",
    "clue_revealed": "The maintenance man was quiet. Competent. He fixed a hinge in the anteroom at 8:50. I watched him for a minute. I don't remember his face. I've tried.",
    "unlocked_by": null
  },
  {
    "witness_id": "wesen_contact",
    "dialogue_key": "dlg_wesen_001",
    "clue_revealed": "Gevatter Tod. Assassin bug kin. The most professional killers in the Wesen world. The wing-case fragment is the only physical evidence they ever leave — and only if rushed. Someone paid a great deal. The killer is already gone. You're looking for who hired them.",
    "unlocked_by": "clue_003"
  },
  {
    "witness_id": "consortium_accountant",
    "dialogue_key": "dlg_accountant_001",
    "clue_revealed": "There was a large untraceable payment from a subsidiary account three weeks ago. I didn't ask what it was for.",
    "unlocked_by": "clue_004"
  },
  {
    "witness_id": "gevatter_contact",
    "dialogue_key": "dlg_gevatter_001",
    "clue_revealed": "The Gevatter Tod have a contact house in the lower port district. If you go there, they'll know a Grimm is looking.",
    "unlocked_by": "clue_001"
  }
],

"grimm_diary_entry": "Gevatter Tod — Godfather Death. Assassin-bug kin. They are the Wesen world's professional killers — not frenzied, not compelled, not addicted. They choose this. Their biology produces a toxin deliverable through a hollow appendage that extends between the fingers. Injection takes less than a second and requires only casual contact. The victim feels nothing. Death in under two minutes. You will not catch a Gevatter Tod at the scene. You catch them by following the money to whoever hired them. Then you face a choice: the hired hand, or the one who gave the order. — Marie Kessler"
```

## PHASE 3 — SUSPECTS
```json
"killer": {
  "name": "Vesper",
  "wesen_type": "Gevatter Tod",
  "motive": "Professional — hired. No personal stake.",
  "alibi": "Already three towns away. Only the contact house connects to them.",
  "alibi_breaks_on": "clue_005 + clue_001 — service entrance timing and puncture wounds reconstruct method",
  "location": "The contact house in the port district"
},

"red_herrings": [
  {
    "name": "Aldous Senn",
    "wesen_type": "Loewen",
    "motive": "The trade route — stood to gain enormously from the vote failing.",
    "alibi": "Dinner with the provincial governor — impeccable.",
    "why_suspicious": "Obvious beneficiary. His consortium directly implicated. But he didn't pull the trigger — he paid for it."
  }
]
```

## PHASE 4 — ACCUSATION
```json
"correct_accusation": {
  "suspect_name": "Vesper",
  "required_clues": ["clue_001", "clue_003", "clue_005", "clue_002"],
  "response_dialogue": "The contact house door opens before you knock. Vesper is sitting at the table. They look entirely ordinary. 'I wondered when,' they say. 'The wing case was sloppy. I was on a schedule.' They fold their hands. 'You know I didn't choose those four men. Someone else decided they should die. I fulfilled the contract.' They tilt their head. 'Are you here for me, or for the man who gave the order? You can't have both tonight.'"
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Aldous Senn",
    "dialogue": "Senn's lawyers are present in minutes. The alibi is airtight. But in the chaos, his accountant quietly hands you the payment record.",
    "consequence": "Senn confirmed as employer via the wrong accusation. Vesper gets more time to prepare."
  }
]
```

## PHASE 5 — CONFRONTATION
```json
"combat_type": "prepared",
"hp": 62,
"woged_description": "Between each finger a hollow chitinous spike extends — 4cm, almost invisible in poor light. Movements economical, precise. They do not look dangerous. That is the point.",
"arena_location": "The contact house — single room, one lamp, minimal furniture. Deliberately cleared.",
"attack_patterns": [
  { "name": "Contact injection", "damage": 0, "type": "melee", "counter": "dodge", "description": "Appears to be a casual touch — the injection happens on contact. Applies toxin status: 15 damage/sec for 4 seconds. Dodge all casual contact." },
  { "name": "Precise strike", "damage": 16, "type": "melee", "counter": "parry", "description": "Direct spike strike. Hardest parry window in chapter 3." },
  { "name": "Feint", "damage": 0, "type": "special", "counter": "none", "description": "Moves as if to inject, switches to precise strike mid-animation. Counter switches." }
],
"phases": 2,
"phase_2_trigger": "HP drops below 30",
"phase_2_change": "Vesper attempts to flee — evasion-focused. Player must cut off exits. If they escape, they leave a note naming Aldous Senn.",
"weakness": null,
"prep_item": {
  "item_name": "Antitoxin wrap",
  "where_found": "Apothecary — requires Lausenschlange scale (case_005) + herbs from cases 005 and 007",
  "effect": "Reduces contact injection damage by 80%. Without it, two injections kill the player."
},
"combat_notes": "Hardest fight so far. The feint makes all counters unreliable. A player who completed cases 005 and 007 will have the prep item ingredients."
```

## PHASE 6 — RESOLUTION
```json
"resolution_text": {
  "vesper_dead_senn_exposed": "Vesper is dead. On the table they left the payment record — insurance against a client who might try to silence them. Aldous Senn's name is on it. The guild masters remain dead. But the man who bought their deaths will answer for it.",
  "vesper_escaped_note_left": "Vesper went through the back wall before you could follow. But the note is on the table — left deliberately. Aldous Senn's name, the payment, and the date. 'Professional courtesy,' it reads. 'I don't like loose ends either.'",
  "wrong_accusation_closed": "Four men remain unavenged. Aldous Senn prospers."
},
"outcome_states": [
  { "state": "vesper_dead_senn_exposed", "text": "Hired killer dead. Employer exposed.", "reward": "90 gold, Gevatter Tod diary entry, Verrat arc item" },
  { "state": "vesper_escaped_note_left", "text": "Killer at large. Employer named.", "reward": "60 gold, Vesper flagged recurring" }
],
"rewards": { "xp": 200, "items": ["Gevatter Tod spike — crafting ingredient", "Senn payment record — arc document"], "diary_entry_unlocked": "Gevatter Tod" },
"unlocks": ["case_013"],
"arc_thread": "verrat_conspiracy"
```

---

## DESIGN NOTES — FULL BATCH 003–012

### Arc threads
- **merchant_quarter_killings**: Cases 003, 005, 007, 010 — a series of deaths in the merchant district ultimately revealing a Verrat-backed economic operation
- **verrat_conspiracy**: Cases 006, 012 — Marta Vaal and the guild murders are both Verrat operations. Senn may be a Verrat agent. Cipher fragment from 006 + payment record from 012 combine into a larger reveal.
- **ritual_killings**: Case 009 — introduces Wesen cultural law as a moral complication
- **forest_road_killings**: Case 004 — standalone, world introduction

### Difficulty curve
004 (Easy) → 005 (Easy-Med) → 006 (Med-Hard) → 007 (Med) → 008 (Med) → 009 (Med) → 010 (Hard) → 011 (Easy-Med) → 012 (Hard)

### New mechanics per case
- 004: Tutorial combat — baseline parry/dodge/block
- 005: Grapple break (K press)
- 006: Grimm blood weakness / stripped-power outcome
- 007: Underbelly vulnerability / addiction phase
- 008: Puzzle-combat hybrid / compelled NPC shields
- 009: Negotiation path / faction reputation system
- 010: Timer mechanic / multi-outcome NPC survival
- 011: Vertical combat
- 012: Prep item requirement / contact status effect

### Recurring characters seeded
- Isolde Varn (Spinnetod, 003) — escaped state
- Karl Metz (Blutbad, 004) — spared state seeds reformed ally
- Marta Vaal (Hexenbiest, 006) — stripped state seeds possible future ally
- Sebastien Moor (Cracher-Mortel, 010) — escaped state
- Vesper (Gevatter Tod, 012) — escaped state, note left, professional respect thread
- Aldous Senn (Loewen, 012) — employer, potential Verrat node

---

*Cases 003–012 complete. Ready for Godot agent import.*
*Each case is self-contained. Arc threads link across files via arc_thread field.*
