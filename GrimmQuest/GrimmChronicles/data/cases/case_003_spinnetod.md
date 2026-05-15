# Case 003 — "The Tailor's Widow"
**Killer Wesen:** Spinnetod (Black Widow Spider)
**Chapter:** 1 | **Difficulty:** Medium

---

## META

```json
"case_id": "case_003",
"case_title": "The Tailor's Widow",
"chapter": 1,
"difficulty": "medium",
"killer_wesen": "Spinnetod",
"fairy_tale_hook": "Rumpelstiltskin / Sleeping Beauty — a beautiful woman who spins and takes from men"
```

---

## PHASE 1 — DISCOVERY

```json
"scene_location": "A prosperous tailor's shop in the merchant quarter. Three bolts of silk knocked from their racks. A stool overturned near the fitting mirror. Candles still lit — death came recently.",

"victim": {
  "name": "Ernst Hübner",
  "wesen_type": "Eisbiber (Beaver)",
  "occupation": "Master tailor, age 34",
  "condition": "Found slumped against the fitting mirror. Expression serene — almost blissful. No visible wounds. Skin pale and papery, as though drained. Three of his finest rings missing from his fingers."
},

"opening_description": "Ernst Hübner was a careful man — he measured twice and cut once, in cloth and in life. His apprentice found him at dawn, sitting against the mirror as if he'd simply fallen asleep. But tailors don't sleep on the floor of their own shops, and men Ernst's age don't grow old overnight. His face tells a story of peace. His body tells something else entirely.",

"time_of_death": "Between 10pm and midnight",
"environmental_hazard": "Narrow stairwell to the upper fitting room — combat movement restricted to single-file"
```

---

## PHASE 2 — EVIDENCE

### Scene Clues

```json
"scene_clues": [
  {
    "clue_id": "clue_001",
    "description": "Two small puncture wounds on the side of the neck — fang-shaped, roughly 4mm apart. Barely visible without close inspection.",
    "points_to": "Spinnetod",
    "found_by_default": true
  },
  {
    "clue_id": "clue_002",
    "description": "Three rings missing from the victim's fingers — his guild seal, a gold band, and a garnet signet. No signs of a struggle suggesting robbery.",
    "points_to": "Spinnetod",
    "found_by_default": true
  },
  {
    "clue_id": "clue_003",
    "description": "The victim's torso is oddly collapsed — ribs intact, but internal cavity feels soft and hollow when pressed. Organs partially dissolved.",
    "points_to": "Spinnetod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_004",
    "description": "A single grey-black hair caught on the brass fitting hook beside the mirror. Too long and fine to be Ernst's.",
    "points_to": "Spinnetod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_005",
    "description": "A faint sweet-chemical smell lingers near the body — not perfume, not rot. Somewhere between the two.",
    "points_to": "Spinnetod",
    "found_by_default": false
  },
  {
    "clue_id": "clue_006",
    "description": "Scratch marks on the inside of the back door lock — picked from the outside, recently.",
    "points_to": "red_herring_suspect_1",
    "found_by_default": false
  },
  {
    "clue_id": "clue_007",
    "description": "An unsigned note tucked under the counter: 'You owe what was promised. Tonight.' Written in a rough hand.",
    "points_to": "red_herring_suspect_2",
    "found_by_default": true
  }
],

"min_clues_to_accuse": 3
```

### Witness Clues

```json
"witness_clues": [
  {
    "witness_id": "lena_apprentice",
    "dialogue_key": "dlg_lena_001",
    "clue_revealed": "A well-dressed woman came in for a fitting two evenings ago. Ernst turned away his last appointment to see her alone. He seemed... captivated.",
    "unlocked_by": null
  },
  {
    "witness_id": "lena_apprentice",
    "dialogue_key": "dlg_lena_002",
    "clue_revealed": "She was striking. Dark hair, very pale skin. She kept glancing at Ernst's hands — at his rings specifically. I thought it was odd at the time.",
    "unlocked_by": "clue_002"
  },
  {
    "witness_id": "georg_neighbour",
    "dialogue_key": "dlg_georg_001",
    "clue_revealed": "I heard voices from the shop around eleven. A woman's laugh — low, soft. Not unpleasant. Then silence.",
    "unlocked_by": null
  },
  {
    "witness_id": "marta_lodginghouse",
    "dialogue_key": "dlg_marta_001",
    "clue_revealed": "A woman matching that description took a room here three days ago. Paid in advance. Hasn't been back since last night. Her trunk is still here — full of men's jewellery.",
    "unlocked_by": "clue_002"
  },
  {
    "witness_id": "marta_lodginghouse",
    "dialogue_key": "dlg_marta_002",
    "clue_revealed": "There was a strange smell from her room. Sweet but wrong, like flowers left in still water too long. I found a single grey glove on the windowsill — the fingers were split at the tips.",
    "unlocked_by": "clue_004"
  },
  {
    "witness_id": "eisbiber_lodge_elder",
    "dialogue_key": "dlg_lodge_001",
    "clue_revealed": "Ernst wasn't the first. Young Pieter the silversmith — same thing, two months ago. And the clockmaker's son before that. All found peaceful. All drained. All missing their finest pieces.",
    "unlocked_by": "clue_003"
  }
],
```

### Grimm Diary Entry

```
"grimm_diary_entry": "Spinnetod — Death Spider. The female of this species is afflicted with a
condition that accelerates her aging if she does not feed. Every few years she must take a young
man's vitality — dissolving his organs through her bite and drawing the dissolved matter back
through her chelicerae. She takes always from men in their prime, and always takes something
shining as a trophy. She is beautiful in human form — impossibly so. By the time a man suspects,
he has already been chosen. Her grey-black hair is distinctive in woge. Her limbs regenerate if
severed. Do not let her climb. She is faster on a vertical surface than on flat ground.
— Marie Kessler, Portland, 2009"
```

### Red Herring Clues

```json
"red_herring_clues": [
  {
    "clue_id": "clue_006",
    "misleads_toward": "Kaspar Voss (Fuchsbau)"
  },
  {
    "clue_id": "clue_007",
    "misleads_toward": "Dietrich Braun (Lausenschlange)"
  }
]
```

---

## PHASE 3 — SUSPECTS

### The Killer

```json
"killer": {
  "name": "Isolde Varn",
  "wesen_type": "Spinnetod",
  "motive": "Compelled feeding cycle — she is beginning to age rapidly and must drain a man's vitality to halt the process. Ernst was chosen for his vitality and his rings.",
  "alibi": "Claims she was at the Golden Stag inn all evening — the innkeeper will confirm she was there until ten.",
  "alibi_breaks_on": "clue_005 + dlg_marta_002 — the smell matches the lodging house, not the inn. The innkeeper is an Eisbiber who was paid to lie and breaks under questioning once the lodge evidence is presented.",
  "location": "Her lodging room at Marta's house — she returns at dawn to collect her trunk before leaving the town."
}
```

### Red Herrings

```json
"red_herrings": [
  {
    "name": "Kaspar Voss",
    "wesen_type": "Fuchsbau (Fox)",
    "motive": "Ernst owed Kaspar money — a debt from a bad fabric deal six months ago. Kaspar had been pressuring him.",
    "alibi": "Was at a Fuchsbau lodge meeting across town — four members can confirm. The lock-picking scratch marks are from a previous visit to demand payment, not last night.",
    "why_suspicious": "The debt note (clue_007) is in his hand. He has a history of 'persuasion'. He has no alibi the player can immediately verify."
  },
  {
    "name": "Dietrich Braun",
    "wesen_type": "Lausenschlange (Boa)",
    "motive": "Ernst was sleeping with Dietrich's wife — Dietrich had found out two weeks ago and threatened him publicly at the market.",
    "alibi": "Was travelling back from a merchants' fair in the next town — documented by a toll receipt stamped at midnight, 4 hours away.",
    "why_suspicious": "Public threats. A constrictor Wesen — the victim's hollow torso could be misread as compression damage. Dietrich is large and visibly angry."
  },
  {
    "name": "Lena Strasser",
    "wesen_type": "Mauzhertz (Mouse) — Ernst's apprentice",
    "motive": "Ernst had just told her he was dismissing her at month's end — she stood to lose her position and lodgings.",
    "alibi": "Asleep in the shop's upper loft — she heard the woman's laugh but saw nothing. Genuinely terrified.",
    "why_suspicious": "She was present in the building. She has motive. She's nervous and evasive — but that's because she's a Mauzhertz near a Grimm."
  }
],
```

### Community NPCs

```json
"community_npcs": [
  { "name": "Georg Tanner", "wesen_type": "Bauerschwein", "role": "Neighbour — heard the laugh, friendly witness" },
  { "name": "Marta Weiss", "wesen_type": "Seelengut", "role": "Lodging house owner — key evidence holder" },
  { "name": "Lodge Elder Rufus", "wesen_type": "Eisbiber", "role": "Links this case to prior Spinnetod killings — pattern witness" },
  { "name": "Innkeeper Brandt", "wesen_type": "Eisbiber", "role": "Provided false alibi for Isolde — breaks under pressure" }
]
```

---

## PHASE 4 — ACCUSATION

```json
"correct_accusation": {
  "suspect_name": "Isolde Varn",
  "required_clues": ["clue_001", "clue_002", "clue_003"],
  "response_dialogue": "She goes still when you name her. Then the shift happens — that slow, terrible smile. 'A Grimm. How long has it been?' She doesn't run. She rolls her neck, and something in her fingers lengthens. 'I was hungry. I am always hungry. Do you know what it is to watch yourself become something ancient and hollowed out? I do what I must.' The rings are lined up on her windowsill like trophies. She steps between you and the door."
},

"wrong_accusation_responses": [
  {
    "suspect_name": "Kaspar Voss",
    "dialogue": "Kaspar stares at you, then laughs — a short, bitter sound. 'You think I killed him? Over a debt? I wanted my money, not his life, you fool.' He pulls out the lodge meeting ledger and drops it at your feet. 'Count the names. Count the hours. Now leave me alone before I start wondering what a Grimm is doing in this town.'",
    "consequence": "Kaspar becomes hostile — will no longer provide information. Lodge elder is now harder to access."
  },
  {
    "suspect_name": "Dietrich Braun",
    "dialogue": "Dietrich goes white, then red. 'I threatened him, yes. Any man would. But I was on the road — check the toll gate, ask the gate keeper.' He grabs his coat. 'I'm going to find a magistrate. You'll answer for this.' He storms out.",
    "consequence": "Dietrich files a complaint — adds a time pressure element. Player has limited moves before the case is complicated by officials."
  },
  {
    "suspect_name": "Lena Strasser",
    "dialogue": "Lena bursts into tears immediately, which tells you nothing. 'I didn't — I would never — he was dismissing me but I — ' She slides down the wall. 'I heard her laughing. I was too scared to come down. I heard everything and I did nothing and he's dead and it's my fault.' She knows more than she's said.",
    "consequence": "Lena reveals the hair clue (clue_004) and the smell (clue_005) in her breakdown — wrong accusation accidentally unlocks two clues."
  }
]
```

---

## PHASE 5 — CONFRONTATION / COMBAT

```json
"combat_type": "standard",
"hp": 55,
"woged_description": "Isolde's fingers split at the tips, each ending in a curved grey claw. Her eyes go entirely black — no iris, no white. Her jaw unhinges slightly, revealing two hollow chelicerae behind her teeth. Her skin takes on a grey-blue sheen. She moves in short, jerking bursts — unnaturally fast when she commits to a direction. She smells of that sweet-wrong chemical the whole fight.",

"arena_location": "The upper fitting room of the lodging house. Narrow, low-ceilinged. A large wardrobe blocks one exit. Two wall-mounted candles. A sloped ceiling on one side.",

"attack_patterns": [
  {
    "name": "Chelicerae lunge",
    "damage": 18,
    "type": "melee",
    "counter": "parry",
    "description": "She lunges forward with an open-mouthed strike — the chelicerae extend just before contact. Parryable on the yellow-eye tell."
  },
  {
    "name": "Acid spit",
    "damage": 12,
    "type": "ranged",
    "counter": "dodge",
    "description": "Short-range spray of digestive fluid. Dodge sideways — it leaves a patch on the floor that deals damage if walked through."
  },
  {
    "name": "Ceiling scramble",
    "damage": 22,
    "type": "special",
    "counter": "block",
    "description": "She moves to the ceiling (using the sloped section) and drops directly down. telegraphed by shadow. Block to reduce damage — can't be dodged or parried."
  },
  {
    "name": "Claw rake",
    "damage": 14,
    "type": "melee",
    "counter": "dodge",
    "description": "A horizontal sweep with both clawed hands at mid range. Dodge back."
  }
],

"phases": 2,
"phase_2_trigger": "HP drops below 25",
"phase_2_change": "Ceiling scramble frequency doubles. She begins combining chelicerae lunge immediately after acid spit with no recovery window. Her tell changes — eye flash becomes faster.",

"weakness": null,
"prep_item": null,

"combat_notes": "The ceiling scramble is the fight's key mechanic — the narrow room means the player can't always get clear of the drop zone. Learning to read the shadow tell is what separates a clean win from an attrition grind. Limb regrowth means severing a claw arm mid-fight doesn't help — it regrows in about 10 seconds."
```

---

## PHASE 6 — RESOLUTION

```json
"resolution_text": {
  "killer_defeated": "Isolde Varn is dead on the floor of the lodging house. The trunk is still there — you count eleven rings, four pocket watches, and a silver locket. Eleven. Ernst was not the first, and she wasn't stopping. You open the locket. A woman, young, stares back at you. Maybe her. Maybe a victim. You can't tell anymore. You take the trunk to the Eisbiber lodge elder. He'll see the families get what he can trace back. The rest goes into the river.",
  "killer_escaped": "You hear the window shatter before you reach the top of the stairs. By the time you're outside she's gone — no trail, no direction. The trunk is gone too. The Eisbiber lodge elder looks at you for a long moment when you tell him. He doesn't say anything. He doesn't have to.",
  "wrong_accusation_closed": "The real killer was gone by morning. The case closes unsatisfied — Ernst Hübner's death goes down as a mysterious illness. Somewhere, a woman with black eyes and grey-tipped fingers is choosing her next fitting appointment."
},

"outcome_states": [
  {
    "state": "killer_defeated",
    "text": "Ernst Hübner — and eleven others — accounted for.",
    "reward": "45 gold, Grimm diary entry: Spinnetod unlocked, +1 reputation with Eisbiber lodge"
  },
  {
    "state": "killer_escaped",
    "text": "Isolde Varn — at large. Will reappear in a later case.",
    "reward": "15 gold, partial diary entry, Isolde flagged as recurring villain"
  },
  {
    "state": "wrong_accusation_closed",
    "text": "Case closed — unsatisfied.",
    "reward": "0 gold, reputation loss with Eisbiber lodge"
  }
],

"rewards": {
  "xp": 120,
  "items": ["Spinnetod chelicerae sample — crafting ingredient", "Ernst's guild seal ring — quest item for later case"],
  "diary_entry_unlocked": "Spinnetod"
},

"unlocks": ["case_004", "npc_isolde_recurring"],
"arc_thread": "merchant_quarter_killings"
```

---

## DESIGN NOTES (for Godot agent)

- The **wrong accusation of Lena** accidentally unlocks two clues — this is intentional. It rewards curiosity and stops wrong accusations from being pure dead ends.
- **Isolde's escaped state** (`killer_escaped`) seeds her as a recurring villain. She should reappear in a later chapter with a new identity, slightly older-looking, new set of trophies.
- The **Eisbiber lodge elder** connects this case to two prior off-screen killings — the silversmith Pieter and the clockmaker's son. These can be referenced in a Grimm diary as cold cases, adding history to the world.
- The **sloped ceiling** in the arena is load-bearing for the combat design — it must exist in the scene geometry or the ceiling scramble attack has no logic.
- **Innkeeper Brandt** (Eisbiber, false alibi) is a minor moral note — he lied out of fear of Isolde, not malice. How the player handles him is flavour, not mechanics.
- Acid spit **floor patches** should persist for 8–10 seconds and visually show as a dark wet stain. They are the environmental hazard in an otherwise straightforward room.

---

*Case file v1.0 — Grimm Chronicles*
