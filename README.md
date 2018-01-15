# ATTENTION: THIS PROJECT HAS ALREADY ENDED UP DEVELOPING !!!
# 注意：此项目已经停止开发
请在<br>
https://github.com/ArHShRn/HealingExtend/tree/02ba1204379e8a078d72d086a05e63faaea3bea5 <br>
下载1.1.1版本的HealingExtend.u文件<br>
# Mutator Version Updated to Release 1.1.1 插件版本更新至 1.1.1
# 注意1.1.2版本回血池有重大BUG请不要下载
-Decrease overclocked health and armor counting down by 20% (Now 0.2xAmmount per second)<br>
-超频血量与护甲每秒减少量降低20%（现在是0.2x回复量）<br>
-Fix version info, now you can use config editor I wrote for this mut<br>
-修复了插件版本信息，现在可以使用我写的1.1.1版本的新配置编辑器了<br>

# THX LIST 感谢名单
Pharrahnox<br>
Teriyakisaurus Rex<br>
Blackout<br>

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
This project is dead, if you find any bug or else, let it go.<br>
此项目已寿尽，如果有任何问题请随缘<br>
