# HealingExtend Plus Version 1.1.3 扩展治疗1.1.3
## THX LIST 感谢名单
Pharrahnox<br>
Teriyakisaurus Rex<br>
Blackout<br>

## READ-ME!! COMPATIBILITY!! 必读！！兼容性！！
### For The New ChatController 对于新的喊话控制器
<b>Warning:</b>The new CC is forked from RPW, but due to RPW BroadcastHandler's initialization procedure:<br><br>
<b>ANY BROADCASTHANDLER CREATED THROUGH THE METHOD IN HE SRC MUST OBEY THE PATTERN OF THE PROCEDURE OF HealingExtend's CHATCONTROLLER(BROADCASTHANDLER) OR YOUR MUTATOR WILL SUFFER FROM UNKNOWN CRTICAL BUGS DUE TO THE COMPATIBILITY!<b><br>
  <br><b>警告:</b>新版本汉化控制器借鉴RPW的喊话控制器，但是由于RPW喊话控制器自身的初始化结构：<br>
  <b>任何通过运用本项目源码中初始化方法的喊话控制器必须严格遵循此项目源码中的代码格式，否则你的插件会因为兼容性而将遭遇严重的随机未知BUG！</b><br>
### For The HE_HUD 对于HE的HUD
  HealingExtend's HE_HUD now can be closed in .ini file with bEnableHE_HUD set to False which means you can use HE in ServerExt servers. :D
  <br><b>Attention: Disable HE_HUD will also disable Overclocking thanks to TWI's unforgettable bugs in KFHUD_Base.</b>
  <br><br>
  HE插件的自身HUD现在可以通过将.ini文件中的bEnableHE_HUD设置成False来关闭，这意味着HE将兼容ServerExt，你们可以把HE用到ServerExt的服务器上面去了<br>
  <b>注意：感谢TWI在KF HUD里面创造的令人难忘的bugs，至此关闭HE_HUD将会强制关闭生命和护甲值超频功能</b><br>
  
## README !! COMMAND LINES !! 必读！启用插件的命令行代码
Though HE's command line is still:<br>
?Mutator=HealingExtend.HE_Main<br>
But <b> DO REMEMBER TO PUT HealingExtend.HE_Main AFTER RPWMod.RestrictPW if you're using RPW!</b> For the compatibilty!<br><br>
虽然HE的命令行代码还是<br>
?Mutator=HealingExtend.HE_Main<br>
但是<b>如果使用了RPW就请务必将HealingExtend.HE_Main放在RPWMod.RestrictPW的后面！</b>，为的是兼容性
