# HealingExtend
Now released Version.1 !
A collection of healing stuffs containing in a small Mutator, intend to extend the original healing methods

# Healing Extend Mutator : Instant Healing
This is the first mutator containing in HealingExtend Mut 
This mutator provides you the possibility to recover Health for a customized health regen rate

# Healing Extend Mutator : Head Shot Recover
his is the second mutator containing in HealingExtend Mut
This mutator provides you the possibility to recover Armour or Health while you just did a single head shot
 
Attention:	You have to do a decap to get the effect !

If you wanna add it on your server, the mutator is supposed to install on a server which is having less than 16 players due to the structure and the process, I'm working on a better way to do it

# About Config
It generates a KFHealingExtend.ini when you use it for the first time, and automatically writes and uses the default settings (which I strongly recommend it !) I tested over times. If you want to modify yourself, plz enjoy it !

[HealingExtend.InstantHealing]
fCurrentRegenRate=40.000000           //Player health regen rate: how much health regen in 1 sec if he's healed
                                      //Official RegenRate is 10
bInitedConfig=True                    //Set this to false to recover every value to author default

[HealingExtend.HeadshotRecover]
dLogTime=30                           //Set how much time to log the headshot been done
bEnableProcessFreqcy=True             //Set if it's enabled to limit healing frequency
bEnableHeadshotCount=False            //Set if it's enabled to see how many head shots are done by him every dLogTime
bAllowOverClocking=True               //Set if it's enabled to reach beyond the max health or armor of a perk
bInitedConfig=True                    //Set this to false to recover every value to author default
bIsEnableDebugSolo=False              //Set if it's enabled to see what target he's aiming at in SOLO game
bIsEnableDebugMsg=False               //Set if it's enabled to see Debug Msg
bIsDebugHeadshot=False
fHealingFreq=0.250000                 //Set how much time (seconds) to process each healing of health or armour
                                      //Value =( 1 / Times ) E.g [Setting it to 0.25 is 4 times' processing]
fDetectRadius=100.000000              //Set the radius of debug ball in solo game which targets your ShotTarget
HealthHealingAmount=3                 // How much health to heal when he does a headshot
ArmourHealingAmount=5                 // How much armour to heal when he does a headshot
HealingMode=0                         // 0 for both, 1 for health only, 2 for armour only
OverclockLimitHealth=175              // The maximum health he can get in Overclocking mode
OverclockLimitArmour=200              // The maximum armour he can get in Overclocking mode

#At Last
Plz Email me if you find bugs or if you have any suggestion to what's next in the mutator (only about healing extending stuff) !

drancickphysix@yahoo.com

Code And Concept By ArHShRn
http://steamcommunity.com/id/ArHShRn/
