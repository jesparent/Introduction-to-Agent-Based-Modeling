breed [variants variant]
variants-own [allele1 allele2 birthrate deathrate v-type fradius home-x home-y]
globals [land-patches land land-color ]

to setup
  clear-turtles
  clear-all-plots
  reset-ticks
  if ( file-exists? "w_eurasia.png" )
    [import-pcolors "w_eurasia.png"]
  set land-color [pcolor] of patch 10 10
  set land-patches count patches with [pcolor = land-color]
  
  setup-patches
  setup-varients
  setup-plot
  update-plot
end

to setup-patches
  set land patches with [pcolor = land-color]
end
  
to setup-varients
  create-variants pop1-number [
    set color red
    set shape "circle"
    set size 1.5
    set birthrate pop1-birthrate
    set deathrate pop1-deathrate
    set allele1 "H"
    set allele2 "H"
    set v-type "pop1"
    put-on-land 1
    set-home
    set fradius fradius-pop1
  ]
  create-variants pop2-number [
    set color blue
    set shape "circle"
    set size 1.5
    set birthrate pop2-birthrate
    set deathrate pop2-deathrate
    set allele1 "h"
    set allele2 "h"
    set v-type "pop2"
    put-on-land 2
    set-home
    set fradius fradius-pop2
  ]
end

to put-on-land [side]  ;; places variants on land only
  ifelse segregate
    [ifelse (side = 1)
      [move-to one-of land with [(pxcor < pop-boundary) and (not any? variants-on self)]]
      [move-to one-of land with [(pxcor > pop-boundary) and (not any? variants-on self)]]
      ]
    [move-to one-of land with [not any? variants-on self]]

end

to set-home
  set home-x [pxcor] of patch-here
  set home-y [pycor] of patch-here 
end

to go
  if  count variants = 0 or (max-generations > 0 and ticks >= max-generations)
    [ stop ]
  ask variants [
    ;; move within foraging radius and stay on land
    setxy home-x home-y
    right random 360
    jump random (fradius + 1)
    if pcolor != land-color [setxy home-x home-y]
     
    Reproduce
    if crowding [
      ifelse count variants > land-patches ;;increase deathrate if agents exceeds available patches
        [if v-type = "pop1" [set deathrate pop1-deathrate * (count variants / land-patches)]
        if v-type = "pop2" [set deathrate pop2-deathrate * (count variants / land-patches)]]
        [if v-type = "pop1" [set deathrate pop1-deathrate]
        if v-type = "pop2" [set deathrate pop2-deathrate]]
    ]
    Check_Death
  ]

  tick
  update-plot
end

to Check_Death
  let rate random 1000
  if rate < deathrate [die]
  ;ifelse (allele1 != allele2 and rate < hybrid-deathrate) 
    ;[die]
    ;[ifelse (allele1 = "H" and rate < pop1-deathrate) 
      ;[die]
      ;[if rate < pop2-deathrate [die]]
    ;]
end

to Reproduce   
  if random 1000 < birthrate [
    let mate one-of other variants in-radius fradius  
    hatch-variants 1 [
      if mate != nobody
        ; if there is another variant to mate with, run routine 
        ; for independent assorment otherwise just clone variant
        [Indep_Assort mate] 
      move-to one-of patches in-radius (fradius + random fradius) with [pcolor = land-color]
      set-home
    ]
  ]
end

to Indep_Assort [mate]
    ;hatch 2 new variants with one allele from each of the parents
    ;set characteristics according to whether it is heterozygote, 
    ;homozygous for HH or homozygous for hh
    ifelse random 2 = 0 [
      ifelse random 2 = 0 
        [set allele2 [allele1] of mate]
        [set allele2 [allele2] of mate]
      ][
        ifelse random 2 = 0 
          [set allele1 [allele1] of mate]
          [set allele1 [allele2] of mate]
      ]
    ifelse allele1 != allele2 [
      set birthrate hybrid-birthrate
      set deathrate hybrid-deathrate
      set v-type "hybrid"
      if random 2 = 0 
        [set shape [shape] of mate
        set size [size] of mate]
      set color yellow
      if random 2 = 1 [set fradius [fradius] of mate]]
      [ifelse allele1 = "H" 
        [set birthrate pop1-birthrate
        set deathrate pop1-deathrate
        set v-type "pop1"
        set color red]
        [set birthrate pop2-birthrate
        set deathrate pop2-deathrate
        set v-type "pop2"
        set color blue]]
end

to setup-plot
  set-current-plot "Population Sizes"
  set-plot-y-range 0 count variants
end

to update-plot
  set-current-plot-pen "pop1"
  plot count variants with [v-type = "pop1"]
  set-current-plot-pen "pop2"
  plot count variants with [v-type = "pop2"]
  set-current-plot-pen "hybrid"
  plot count variants with [v-type = "hybrid"]
end




; Copyright 2010 by Michael Barton.  All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from Michael Barton.
; Contact Michael Barton for appropriate licenses for redistribution for
; profit.
;
; To refer to this model in academic publications, please use:
; Barton, C.M. (2010).  NetLogo Hominin Hybridization Model.
@#$#@#$#@
GRAPHICS-WINDOW
145
230
910
596
-1
-1
5.0
1
10
1
1
1
0
0
0
1
0
150
0
66
1
1
1
ticks

BUTTON
80
10
135
43
run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
5
10
60
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
5
200
134
233
pop2-number
pop2-number
1
1000
400
1
1
NIL
HORIZONTAL

SLIDER
5
50
135
83
pop1-number
pop1-number
1
1000
400
1
1
NIL
HORIZONTAL

PLOT
510
10
905
220
Population Sizes
Time
Number
0.0
100.0
0.0
70.0
true
true
PENS
"pop1" 1.0 0 -2674135 true
"pop2" 1.0 0 -13345367 true
"hybrid" 1.0 0 -10899396 true

SLIDER
5
85
135
118
pop1-birthrate
pop1-birthrate
1
1000
6
1
1
NIL
HORIZONTAL

SLIDER
5
235
135
268
pop2-birthrate
pop2-birthrate
1
1000
6
1
1
NIL
HORIZONTAL

SLIDER
5
120
135
153
pop1-deathrate
pop1-deathrate
1
1000
6
1
1
NIL
HORIZONTAL

SLIDER
5
270
135
303
pop2-deathrate
pop2-deathrate
1
1000
6
1
1
NIL
HORIZONTAL

SLIDER
5
350
135
383
hybrid-birthrate
hybrid-birthrate
1
1000
7
1
1
NIL
HORIZONTAL

SLIDER
5
385
135
418
hybrid-deathrate
hybrid-deathrate
1
1000
6
1
1
NIL
HORIZONTAL

SWITCH
5
465
135
498
segregate
segregate
0
1
-1000

SLIDER
5
155
135
188
fradius-pop1
fradius-pop1
1
30
16
1
1
NIL
HORIZONTAL

SLIDER
5
305
135
338
fradius-pop2
fradius-pop2
1
30
16
1
1
NIL
HORIZONTAL

SWITCH
5
500
135
533
crowding
crowding
1
1
-1000

INPUTBOX
390
10
495
70
max-generations
1500
1
0
Number

BUTTON
150
10
205
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
395
80
495
135
You must press <return> after changing max-generation
10
0.0
1

SLIDER
5
430
135
463
pop-boundary
pop-boundary
0
150
85
1
1
NIL
HORIZONTAL

TEXTBOX
155
260
305
290
1 cell = 0.46 x 0.46 degees = 52km (EW) x 30km (NS)
11
139.0
1

TEXTBOX
145
55
295
151
Note: You must press the SETUP button after changing a population parameter (such as birthrate) in order for that change to register with the agents.
11
0.0
1

MONITOR
850
80
905
125
pop1
count variants with [v-type = \"pop1\"]
0
1
11

MONITOR
850
125
905
170
pop2
count variants with [v-type = \"pop2\"]
0
1
11

MONITOR
850
170
905
215
hybrid
count variants with [v-type = \"hybrid\"]
0
1
11

@#$#@#$#@
MODEL OVERVIEW
-----------
This model simulates genetic interaction and hybridization between two populations in western Eurasia during the Upper Pleistocene, using a simple two allele system.

MODEL FUNCTION
------------
INIITAL STATE: The model is initiated with two different variant populations of individual agents, each of whom is homozygous (HH or hh). Western Eurasia is represented by a graphic file named w_eurasia.png, which must exist in the same folder/directory as the netlogo model. The w_eurasia.png file supplied represents the Upper Pleistocene coastline. The agents of each of the two populations are distributed randomly across the land area (identified by the color at cell 10,10). The can be  interspersed (i.e., conditions of panmixia) or spatially segregated depending on a user-controlled switch. If segregated, individuals of variant 1 will be west (i.e., left) of a vertical line defined by the population-boundary slider and individuals of variant 2 will be east (i.e., right) of this line.

AGENTS: Each individual has a genome (<allele1> and <allele2> = "H" or "h") <birthrate> (0-1000), <deathrate> (0-1000), type <v-type> ("pop1", "pop2", or "hybrid"), a foraging radius <fradius> (1-30), and a 'home base' specified by xy coordinates <home-x> and <home-y>

MOVEMENT: Each cycle, individual agents begin at their home base and randomly jump to a patch within a foraging radius <fradius> set by the user for each population <fradius-pop1> and <fradius-pop2>.

REPRODUCTION: The user can set the birthrate (n per 1000) for population 1 (HH) <pop1-birthrate>, population 2 (hh) <pop2-birthrate>, and hybrids (Hh) <hybrid-birthrate>. For each cycle, the simulation calculates a random number between 0-1000 for each individual. If the number is <= birthrate, the individual reproduces. A new individual will jump to a new location that is randomly selected to be > 1 foraging radius <fradius> and < 2 foraging radii distant from the parent home base. 

For each individual, the simulation checks whether another individual is found within the foraging radius around its home base. If not, the individual is simply cloned. If there are other individuals, one is chosen at random to mate with the first individual.

When an individual mates with another individual, a genetic 'independent assorment' routine randomly assigns either allele1 OR allele2 of the hatched offspring to the value of either allele1 OR allele2 of each of the mating individuals.

DEATH: The user can also set the death rate <deathrate> of each population (<pop1-deathrate>,  <pop2-deathrate>, and <hybrid-deathrate>). Each cycle, the simulation calcuates a random number between 0-1000 for each individual. If the number is <= deathrate, the individual dies.

CROWDING: When <crowding> is set to true (switch set by user), the total deathrate is increased if the total agent population exceeds the total number of patches in the world. When the population exceeds the patch total, deathrate of each agent is recalculated as deathrate(c) = deathrate * (total individuals / total patches).

STARTING THE SIMULATION
-------------
Sliders allow the user to set the initial number of individuals in each homozygous population <pop1-number> and <pop2-number>

The SETUP button imports the landscape (w_eurasia.png) and initializes the model. the RUN button starts and stops the model. Pressing STEP rather than RUN will manually step through each cycle.

The simulation can be set to stop after a specific number of cycles by entering that number in max-generations box. You must press RETURN after entering a number. Entering 0 will cause the simulation to run continuously until the RUN button is pressed.

A plot monitor shows the total number of HH individuals, hh individuals, and hybrid Hh individuals.


THINGS TO TRY
-------------
Vary the birth and death rates of hybrids a little and see the effects on the homozygote individuals (e.g., try to create a "balanced polymorphism"). 

Vary the initial balance between populations 1 and 2.

Change the foraging radius and see how it affects hybridization rates.

Add then remove a barrier between populations to see its effects.

Try it in 3D


EXTENDING THE MODEL
-------------------
Different landscapes could be used to alter the geographical constraints on the agents. The landscape and land color could be user-selectable.


RELATED MODELS
--------------
hominin_ecodynamics2.0


CREDITS AND REFERENCES
----------------------
C. Michael Barton, Arizona State University. Copyright 2008

Barton, C Michael, Julien Riel-Salvatore, John M. Anderies, and Gabriel Popescu. "Modeling human ecodynamics and biocultural interactions in the Late Pleistocene of western Eurasia." Human Ecology (2011). doi:10.1007/s10745-011-9433-8
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

box 2
false
0
Polygon -7500403 true true 150 285 270 225 270 90 150 150
Polygon -13791810 true false 150 150 30 90 150 30 270 90
Polygon -13345367 true false 30 90 30 225 150 285 150 150

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

train switcher engine
false
0
Polygon -7500403 true true 45 210 45 180 45 150 53 130 151 123 248 131 255 150 255 195 255 210 60 210
Circle -16777216 true false 225 195 30
Circle -16777216 true false 195 195 30
Circle -16777216 true false 75 195 30
Circle -16777216 true false 45 195 30
Line -7500403 true 150 135 150 165
Rectangle -7500403 true true 120 90 180 195
Rectangle -16777216 true false 132 98 170 120
Line -7500403 true 150 90 150 150
Rectangle -16777216 false false 120 90 180 180
Rectangle -7500403 true true 30 180 270 195
Rectangle -16777216 false false 30 180 270 195
Line -16777216 false 270 150 270 180
Rectangle -1 true false 245 131 252 138
Rectangle -1 true false 48 131 55 138
Polygon -16777216 true false 255 179 227 169 227 158 255 168
Polygon -16777216 true false 255 162 227 152 227 141 255 151
Polygon -16777216 true false 45 162 73 152 73 141 45 151
Polygon -16777216 true false 45 179 73 169 73 158 45 168
Rectangle -16777216 true false 112 195 187 210
Rectangle -16777216 true false 264 180 279 195
Rectangle -16777216 true false 21 180 36 195
Line -16777216 false 30 150 30 180
Line -16777216 false 120 98 180 98

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment 1a - vary hybrid birthrate, fradius = 2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 1b - vary hybrid birthrate, fradius = 4" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 1c - vary hybrid birthrate, fradius = 8" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 1d - vary hybrid birthrate, fradius = 16" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 1e - vary hybrid birthrate, fradius = 32" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 2 - vary hybrid birthrate, different fradius for pop1 and pop2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <metric>count variants with [v-type = "pop2"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 3 - vary hybrid birthrate, equal initial populations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count variants with [v-type = "pop1"]</metric>
    <metric>count variants with [v-type = "pop2"]</metric>
    <enumeratedValueSet variable="fradius-pop2">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="segregate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-generations">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-number">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="crowding">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hybrid-birthrate">
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop2-birthrate">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-number">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-boundary">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fradius-pop1">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop1-deathrate">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
