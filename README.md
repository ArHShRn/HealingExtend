# HealingExtend
Now released Version.1 !
A collection of healing stuffs containing in a small Mutator, intend to extend the original healing methods

## Healing Extend Mutator : Instant Healing <br>
This is the first mutator containing in HealingExtend Mut<br>
This mutator provides you the possibility to recover Health for a customized health regen rate<br>

## Healing Extend Mutator : Head Shot Recover<br>
his is the second mutator containing in HealingExtend Mut<br>
This mutator provides you the possibility to recover Armour or Health while you just did a single head shot<br>
<br> 
Attention:	You have to do a decap to get the effect !<br>
<br>
If you wanna add it on your server, the mutator is supposed to install on a server which is having less than 16 players due to the structure and the process, I'm working on a better way to do it<br>

## About Config<br>
It generates a KFHealingExtend.ini when you use it for the first time, and automatically writes and uses the default settings (which I strongly recommend it !) I tested over times. If you want to modify yourself, plz enjoy it !<br>

### [HealingExtend.InstantHealing]<br>
fCurrentRegenRate=40.000000           //Player health regen rate: how much health regen in 1 sec if he's healed<br>
                                      //Official RegenRate is 10<br>
bInitedConfig=True                    //Set this to false to recover every value to author default<br>
<br>
### [HealingExtend.HeadshotRecover]<br>
dLogTime=30                           //Set how much time to log the headshot been done<br>
bEnableProcessFreqcy=True             //Set if it's enabled to limit healing frequency<br>
bEnableHeadshotCount=False            //Set if it's enabled to see how many head shots are done by him every dLogTime<br>
bAllowOverClocking=True               //Set if it's enabled to reach beyond the max health or armor of a perk<br>
bInitedConfig=True                    //Set this to false to recover every value to author default<br>
bIsEnableDebugSolo=False              //Set if it's enabled to see what target he's aiming at in SOLO game<br>
bIsEnableDebugMsg=False               //Set if it's enabled to see Debug Msg<br>
bIsDebugHeadshot=False<br>
fHealingFreq=0.250000                 //Set how much time (seconds) to process each healing of health or armour<br>
                                      //Value =( 1 / Times ) E.g [Setting it to 0.25 is 4 times' processing]<br>
fDetectRadius=100.000000              //Set the radius of debug ball in solo game which targets your ShotTarget<br>
HealthHealingAmount=3                 // How much health to heal when he does a headshot<br>
ArmourHealingAmount=5                 // How much armour to heal when he does a headshot<br>
HealingMode=0                         // 0 for both, 1 for health only, 2 for armour only<br>
OverclockLimitHealth=175              // The maximum health he can get in Overclocking mode<br>
OverclockLimitArmour=200              // The maximum armour he can get in Overclocking mode<br>
<br>
## At Last<br>
Plz Email me if you find bugs or if you have any suggestion to what's next in the mutator (only about healing extending stuff) !<br>
<br>
drancickphysix@yahoo.com<br>
<br>
Code And Concept By ArHShRn<br>
http://steamcommunity.com/id/ArHShRn/<br>
