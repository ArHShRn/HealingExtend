# Mutator Version Updated to Release 1.1.1 插件版本更新至 1.1.1
-Decrease overclocked health and armor counting down by 20% (Now 0.2xAmmount per second)<br>
-超频血量与护甲每秒减少量降低20%（现在是0.2x回复量）<br>
-Fix version info, now you can use config editor I wrote for this mut<br>
-修复了插件版本信息，现在可以使用我写的1.1.1版本的新配置编辑器了<br>

# THX LIST 感谢名单
Pharrahnox<br>
Teriyakisaurus Rex<br>
Blackout<br>

# What are the changes in Release 1.1.0 ? 版本1.1.0有哪些改动？
## Balance Changes 平衡性改动
-Medic perk will not see teammates' health status when they're hidden.<br>
-医疗不再能够透视队友的血量<br><br>
-Recovery cooling down time is removed, but you will still lost records if you decap too fast.<br>
-回复冷却时间被取消了，但是爆头太快还是不会被记录进插件并触发回复<br><br>
-Overclocked health and armor will count down in 0.25 * Recovery_Speed till it's standard.<br>
-超频获得的护甲与生命值将会以 恢复速率x0.25 的速度减少，直至回到你的职业标准血量<br><br>
-Normal recovery will only recover your armor onto at most your perk's armor limit, instead of 175.<br>
-普通回复最多只会将你的护甲回复到 职业标准护甲量 而不是以前的175甲了<br><br>
-You can't get infinite recovery at a "decaped-but-dying" any more.<br>
-你不再能够从掉了头但是还没有死的ZED身上刷取无限制的回复量了<br><br>
## Main Mutator class 插件主要部分
1.Completely rework mutator strcture, makes it more effient and stable to run.<br>
2.Shows the Zed's (class) name who kills you last wave.<br>
3.Applied balance changes to this class, details see above.<br>
<b>4.Add chat controller and trader manager.</b><br>
1.插件结构完全被重写，增加了插件的效率与运行稳定性<br>
2.将会提示上波杀死你的ZED名称（类名）<br>
3.对此类进行了平衡性改动，详细参考上文<br>
<b>4.增加了喊话控制和商人功能（自定义武器）</b><br>

## Healing Extend HUD Base class HE插件HUD部分
1.Add customized icon, but you can decide to use it or not by downloading .upk or not<br>
if you have .upk, you will see Fleshpound and Scrake notification when there are few zeds left,<br>
and you will also have a PS-draw crosshair.<br>
if you have no .upk, you will see the original HUD zeds notification and old version Crosshair.<br>
2.Changed health bar color to elder version of KF2<br>
1.增加了自订图标，但是你可以通过下载或者不下载.upk文件来决定使不使用<br>
如果你下载了.upk文件，你会在还剩几个ZED的时候看到SC或者FP的位置提示（如果有的话），而且有PS画出来的准心<br>
如果你没有下载.upk文件，你的ZED提示会和原版KF2一样，准心将会是此插件早期版本的十字带点准心<br>
2.改变了血条的颜色为 护甲：蓝 血量：红，回归早期KF2版本样式

## Healing Extend Mutator - Chat Controller HE插件喊话控制
1.Create this class xD, it's like CD's chat commander.<br>
2.You can control mutator's config dynamiclly when you're playing, it will be applied when the wave is ended.<br>
3.You can check mutator's version, current config, or call help to know what commands you can use.<br>
4.You have to gain Full-Access Admin control to control the mutator settings. You'll have the admin access to chat controller if you login as admin of the server or you're me xD.<br>
5.The way to use it is listed at bottom.<br>
1.创建了这个东东，和CD的汉化控制非常类似<br>
2.你可以动态控制插件的设置数据，每波结束后会应用更改<br>
3.你可以查看插件版本、目前设置信息、帮助信息<br>
4.你必须要有管理员访问权限才能够控制插件设置，获取管理员权限的话你必须作为管理员登录服务器或者你是作者！xD<br>
5.具体使用方法请看下文介绍<br>

## Healing Extend Mutator - Trader Manager HE内嵌商人插件
1.Create this class xD for later usage of customized weapons.<br>
2.For now, I add two balanced weapons:401 BiohaZar and 201 Storm in trader and they're only associated to Medic.<br>
1.创建了这个东东，为了以后能够加入自订武器进去<br>
2.现在来说，平衡版的401和201已经被加入了商人，但是仅被关联到医疗职业<br>

# Update Method and Compatibility 插件升级方法以及兼容性
This mut has its own HUD and I created one No_HUD version before, but this is ver 1.1.0 and I didn't create one for this version because it has too many features associated to the HUD, so I may not write a No_HUD version for every version of the mutator.
And this mutator is not compatible with any mode that has its own HUD!<br>
这个插件有自己的HUD而且之前的版本我重写了一个无HUD版本的插件加入进去，但是因为这是新版本1.1.0所以我没有给这个版本写无HUD版本，因为目前为止它具有太多与自订HUD相关的功能了，而且之后我也不会给每个版本单独写一个无HUD版本出来了。<br>
所以这个插件不支持任何带有自制HUD的插件！例如RPG MOD<br>
To update the mutator, you need to delete KFHealingExtend.ini (Version 0.1.2) or KFHE_Main.ini (Version 1.0.1) in your config folder and run the mutator for at least once.<br>
为了升级插件，你需要将原有的配置文件删除，对应的是KFHealingExtend.ini (版本号 0.1.2) 或者 KFHE_Main.ini (版本号 1.0.1)，然后至少运行插件一次<br>

# How to use Chat Controller 怎么使用喊话控制
First, it's <b>not case sensitive</b>, you can type whatever case you want.<br>
<b>Atfer you're spawned in the game</b>, please check console if there's any message sent from ChatController, if there is then it works fine.<br>
ChatController detects what you've said in chat box and only identifies the commands like following structure:<br>
<b> #HE{Header} <Argument> [Parameter]</b>
  and current available headers are : Sys, Cfg;<br>
 #HESys commands:<br>
  #HESys //Check mutator version info<br>
  #HESys Details (#HESys Brief) //show brief current config info<br>
  #HESys DetailsFull (#HESys Full) //show detailed current config info in console<br>
  #HESys Admin //try to gain admin control of the mutator<br>
  #HESys Help //check the help information<br>
 #HECfg commands:<br>
  #HECfg RengenRate [Parameter] (#HECfg RR [Parameter]) //modify health rengeneration rate<br>
  #HECfg RecoverAmmo [Parameter] (#HECfg RA [Parameter]) //modify if it recovers ammo<br>
  #HECfg AAR [Parameter] //modify if it uses AAR headshot detection<br>
  #HECfg GetDosh [Parameter] (#HECfg GD [Parameter]) //modify if you can get dosh bonus<br>
  #HECfg HealingAmmount [Parameter] (#HECfg HA [Parameter]) //modify health healing ammount<br>
  #HECfg ArmorGain [Parameter] (#HECfg ArmourGain [Parameter]) (#HECfg AG [Parameter]) //modify ArmorGain ammount<br>
  #HECfg DoshBonus [Parameter] (#HECfg DB [Parameter]) //modify dosh bonus ammount<br>
PLEASE NOTIFY: Overclocking stuffs can't be changed in Dynamic Settings, please change in .ini before you run<br>
  首先，喊话控制<b>大小写不敏感</b>, 你可以随便输入大写或者小写命令<br>
<b>当你在游戏里面出生过后</b>, 请看看控制台里面有没有ChatController消息发出，如果有的话说明运行良好<br>
喊话控制会检测你在ChatBox里面所说的话，并且识别包含下列结构的命令<br>
<b> #HE{头部参数} <论据> [参数]</b>
  目前可用的头部有 : Sys, Cfg;<br>
 #HESys 命令:<br>
  #HESys //显示插件目前版本信息<br>
  #HESys Details (#HESys Brief) //显示简化的插件目前设置<br>
  #HESys DetailsFull (#HESys Full) //在控制台显示详细的插件目前设置<br>
  #HESys Admin //试着获取插件的管理员控制权限<br>
  #HESys Help //显示帮助信息<br>
 #HECfg 命令:<br>
  #HECfg RengenRate [Parameter] (#HECfg RR [Parameter]) //更改回血速率<br>
  #HECfg RecoverAmmo [Parameter] (#HECfg RA [Parameter]) //更改是否回复子弹<br>
  #HECfg AAR [Parameter] //更改是否使用AAR爆头检测<br>
  #HECfg GetDosh [Parameter] (#HECfg GD [Parameter]) //更改是否有爆头金钱奖励<br>
  #HECfg HealingAmmount [Parameter] (#HECfg HA [Parameter]) //更改回血量<br>
  #HECfg ArmorGain [Parameter] (#HECfg ArmourGain [Parameter]) (#HECfg AG [Parameter]) //更改回甲量<br>
  #HECfg DoshBonus [Parameter] (#HECfg DB [Parameter]) //更改爆头金钱奖励数目<br>
请注意： 超频设置不能在动态设置里面更改，请在运行之前在.ini配置文件中更改<br>

## At Last 最后<br>
Plz Email me if you find bugs or if you have any suggestion to what's next in the mutator (only about healing extending stuff) !<br>
And you're welcomed to provide weapon datas for me to be written into the mut as the customized weapons!<br>
如果你找到任何BUG或者有一些小建议清邮我！而且如果你对武器数据有见解的话也请将改动数据邮给我！<br>
<br>
drancickphysix@yahoo.com<br>
<br>
Code And Concept By ArHShRn<br>
http://steamcommunity.com/id/ArHShRn/<br>
