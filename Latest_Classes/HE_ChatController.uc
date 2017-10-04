//=============================================================================
// Healing Extend Mutator : Chat Controller
// This class get chatbox's chat messages and act as the player says something
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.3.0
// -Created this class
//
// Principle Explanation:
//	1.How to respond what players have said ?
//	To successfully respond to what players have said in ChatBox, first we need to access ChatBox
//	to get the right contents we want, since UnrealScript provides us some ActionScript APIs and KF2's
//	ChatBox is a kind of GFxObject things, so we use these APIs to get what we've received in the ChatBox
//
//	2.How to get ChatBox messages ?
//		Function : GetDataObjects():GFxObject 
//	returns datas stored in the ChatBox while we're having several messages retaining in it, 
//	and we use 
//		Function GetString("label"):String 
//	to get it! And then we need to do some string parsing stuffs,
//	to get our expected commands into some right formats which can be identified by the class,
//	that's what you have to do with, so you're doing it on your own and I'll not explain
//  it in detail. I wrote a kind of solution in this class and you can refer to it.
//
//	3.What if I use ChatController online ?
//  At last we have to deal with Replication while our mutator is running at a server. 
//	What I've done before it to spawn an instance for each KFPlayerController,
//	and use Client and Server Functions to manage them, and use Tick event in class HE_Main
//	but I found it responding with several same messages instead of only one. At last I found the reason.
//	You may spawn a manager(controller) for each player,
//	but there's one question: How can we respond a global msg for what a specific player has said ?
//	I wrote a reliable server 'SayForAll' function, which is replicated to server side doing ForEach things,
//	that means, for each ChatController in the WorldInfo, no matter whose ChatController,
//	will respond with a msg coming out in the ChatBox, so there will be %PlayerNumbers% same msg,
//	and they're just responding a single one's chat command, each for once.
//	Now I still spawn one CC for each player, but when you think carefully you will observe that:
//	ChatBox Messages are global, which means we can see others' messages, this is inspiring,
//	because you can "assume" the message is sent by yourself and process it in YOUR client, respond locally,
//	and for every player, this is the same, which means everyone can still see the response for the msg,
//	like it's globally notified, so the "say" stuffs are worked out.
//
//	4.What RemoteRole should I use for this class ?
//	OF COURSE --Role_AutonomousProxy--
//	This controller is directly controlled by player himself, which means it will accept player's input
//	and change values inside itself. This is important, because SimulatedProxy only simulates things,
//	it doesn't handle the main control, it just compares the value with Server-Side role and updates to
//	what the Server-side role tells it to be, this means you can't change values locally and send them,
//	this also means you can't do "dynamic settings" stuffs.
//	But using Role_AutonomousProxy and ReplicatedEvent can perfectly handle it.
//	And if you really don't want to use Role_AutonomousProxy, you can still use Role_SimulatedProxy,
//	but you have to keep values up-to-date in server side using "reliable server function" or else.
//
//	5.How does Dynamic Settings work ?
//	I will say: it's a little trick.
//	To dynamicly control server-side configs, first we have to know: what settings does server use?
//	So we have to deliver configs from server to client, let LocalPlayer and local CC know the configs.
//	Once we clearly know the configs, we can change it.
//	So step two is to identify "config command" in ChatBox, refer to 2. I said before.
//	And step three, we should let server know we changed it!
//	On server side, I use Tick event in HE_Main to check and receive new configs. This needs replication.
//
//	6.Why does the class have a bool variable "FullAccess" ?
//	It's simple: Don't Let Any Bad People Change Your Configs Casually.
//	The principle is simple too. Since configs are set from server using "reliable client function",
//	Server-side class have no valid values in configs, and only if one class has "FullAccess" can
//	the configs be replicated to server-side class and let HE_Main check it in Tick event.
//
// Last Update Date Oct.3rd 2017
//=============================================================================
class HE_ChatController extends Actor
	DependsOn(HE_Datastructure)
	Config(HE_ChatController);
	
//*********************************************************
//* Variables
//*********************************************************
var HEConfig					HE_MainConfig;

var GameViewportClient			LocalGVC;
var Console						LocalC;
var HECommand					Commands;

var KFPlayerController			Trigger;

var bool						FullAccess;
var repnotify bool				bIsWaveActive;

var array<GFxObject>			retVal;
//*********************************************************
//* Replication
//*********************************************************
Replication
{
	if(Role == Role_Authority && WorldInfo.NetMode != NM_Standalone)
		bIsWaveActive;
}

simulated function ReplicatedEvent(name VarName)
{
	if(VarName == 'bIsWaveActive')
		ClientPrint("Notify Wave Status Changed = "$bIsWaveActive,True);
}

//*********************************************************
//* Initialization
//*********************************************************
//Init commands
simulated function PreBeginPlay()
{
	//Empty Commands
	Commands.CommandHead="";
	Commands.UserName="";
	Commands.Argument="";
	Commands.Parameter="";
	Commands.Value="";
	super.PreBeginPlay();
}

//PostBeginPlay
//Get console, log status
//ATTENTION: Trigger should be got at ModifyPlayer
//				Or it will be set to None
simulated function PostBeginPlay()
{
	//If it's client side or standalone game
	//Online game: Server side manager shouldn't have any LocalPlayer
	//	and nerver will it.
	if(Role < Role_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		//Get LocalGVC to search for the player chat messages in console
		`log("---[HE_ChatController::PostBeginPlay]Initializing Local Game View Port");
		LocalGVC=class'GameEngine'.static.GetEngine().GameViewport;
		if(LocalGVC != None)
		{
			LocalC = LocalGVC.ViewportConsole;
			if(LocalC != None)
				`log("---[HE_ChatController::PostBeginPlay]Get a local console.");
		}
		else
			`log("---[HE_ChatController::PostBeginPlay]Error getting a local console!");
	
		`log("---[HE_ChatController::PostBeginPlay]End PostBeginPlay");
	}
	
	//If it's server side
	if( Role == ROLE_Authority && WorldInfo.NetMode == NM_DedicatedServer )
	{
		`log("---[HE_ChatController::PostBeginPlay]Server Side Enters PostBeginPlay.");
	}
	super.PostBeginPlay();	

	`log("--HE_ChatController Initialization Status As Following--");
	`log("The class is initialized at "$WorldInfo.NetMode);
	`log("Current Role="$Role);
	`log("Current RemoteRole="$RemoteRole);
	`log("Current Owner="$Owner);
	`log("--------------------------------------------------------");
}

//*************************************************************
//* Helper Functions
//*************************************************************
/**
 * Helper function to get the LocalPlayer
 */
//LocalPlayer is created right after the game entered
//Just like PostBeginPlay, even before the KFPC is created
simulated function PlayerController GetLPPC()
{
	local LocalPlayer LocalPlayerOwner, tmp;

	LocalPlayerOwner = class'Engine'.static.GetEngine().GamePlayers[0];
	`log("---[HE_ChatController::GetLPPC]GamePlayers.Length = "$class'Engine'.static.GetEngine().GamePlayers.Length);
	ForEach class'Engine'.static.GetEngine().GamePlayers(tmp)
	{
		if(tmp ==None)
			`log("---[HE_ChatController::GetLPPC]WARNING: Find none LP in GamePlayers!");
		else
			`log("---[HE_ChatController::GetLPPC]GamePlayers = "$tmp.Name);
	}
	
	if (LocalPlayerOwner == none)
	{
		`log("---[HE_ChatController::GetLPPC]WARNING: Find NONE LocalPlayer !");
		return none;
	}
	`log("---[HE_ChatController::GetLPPC]Return LocalPlayer.Actor "$LocalPlayerOwner.Actor);
	return LocalPlayerOwner.Actor;
}

//To get Trigger
simulated function GetTrigger()
{
	Trigger = KFPlayerController( GetLPPC() );
	if(Trigger == None)
	{
		`log("---[HE_ChatController::GetTrigger]WARNING: Get no Trigger !");
		return;
	}
	`log("---[HE_ChatController::GetTrigger]This trigger instance PlayerName = "$Trigger.PlayerReplicationInfo.PlayerName);
}

//Client Get Trigger
//Online game: Every client will have its own local player
//	for only one, and we call it the Trigger
reliable client function ClientGetTrigger()
{
	GetTrigger();
}

//Print sth in console
simulated function Print( string message, optional bool autoPrefix = true )
{
	if ( autoPrefix )
	{
		message = "[HE Chat Controller Msg]"$message;
	}

	if ( LocalGVC != None )
	{
		LocalGVC.ViewportConsole.OutputTextLine(message);
	}
}

//Let CC know if the wave is active
function NotifyWaveActivity(bool isActive)
{
	bIsWaveActive = isActive;
}
//*********************************************************
//* Tests & Exec
//*********************************************************

//*********************************************************
//* Functions: String Parsing N' ServerSide Notification
//*********************************************************
//Get chat messages from GFx ChatBox
simulated function string GetChatMessage(optional out int isNone)
{
	local string ConsoleString;
	isNone=0;
	
	if(Trigger==None)
	{
		isNone = 1;
		return "Error:No Local Player Find";
	}
	
	if(Role == ROLE_Authority && WorldInfo.NetMode == NM_DedicatedServer)
	{
		isNone = 1;
		return "Cancel: Dedicated Server";
	}
	
	//First get GfxObjs in ChatBOX
	//Main method to get chat box lines
	retVal = Trigger.MyGFxHUD.HudChatBox.GetDataObjects();
	if(retVal.Length == 0)
	{
		isNone=1;
		return "Error: Can't Get GFxObjects In ChatBox!";
	}
	
	//Get the latest chat message
	ConsoleString = retVal[0].GetString("label");
	
	return ConsoleString;
}

//Check get status
simulated function bool CheckAndGetPlayerChat()
{
	local string ConsoleString;
	local int isNone;

	ConsoleString = GetChatMessage(isNone);
	
	if(isNone==1)
		return False;
	
	if(ParsingCommand(ConsoleString))
		return True;
	
	return False;
}

//Parsing commands into HECommand structure
simulated function bool ParsingCommand(string str)
{
	local string tmp;
	local int space, header;
	//Sample: The gotten ConsoleString is like following pattern
	//<@	> ArHShRn #AFK: #HESys Details 66
	
	//Search for command identification
	header = InStr(Caps(str), "#HE", False, True,);
	//If it's not a HECommand Line, don't act
	if(header == -1)
		return False;
		
	//Get the command a right format
	//Delete <@ > in front
	space = InStr(str, ">", False, True);
	tmp = Right(str, Len(str) - space - 2); //After="ArHShRn #AFK: #HESys Details 66"
	//Get PlayerName
	space = InStr(tmp, ":", False, True);
	Commands.UserName = Left(tmp, space);
	//Delete Username in front
	tmp = Caps( Right(tmp, Len(tmp) - space - 2) );//After="#HESYS DETAILS 66";
	
	//Parsing commands
	Commands.CommandHead = "#HE";
	Commands.Argument = Left(tmp, 6);
	if(Commands.Argument == "#HESYS")
	{
		Commands.Parameter = Right(tmp, Len(tmp)-6);//" DETAILS"
		return True;
	}
	
	//#HECFG stuffs
	//Right(tmp, Len(tmp)-6)=" DETAILS 66"
	tmp = Right( tmp, Len(tmp) - 6 );//" DETAILS 66"
	tmp = Right( tmp, Len(tmp) - 1 );//"DETAILS 66"
	space = InStr( tmp, " ", False, True);
	if(space==-1)
		return False;
	Commands.Parameter = " "$Left( tmp, space );//"DETAILS"
	Commands.Value = Right( tmp, Len(tmp) - space - 1);//"66"
	return True;
}

//Notify that it's time to re-check changes in ChatBox
//Used by Server HE_Main
reliable client function Recheck()
{	
	//if( Role == ROLE_Authority && WorldInfo.NetMode == NM_DedicatedServer)
		//return;
		
	//If failed to get identified msg
	if(!CheckAndGetPlayerChat())
		return;

	//Else the simulated proxy will process it
	Process();	
	
	//And afterward the Commands should be empty to
	//  restore next msg
	Commands.CommandHead="";
	Commands.Argument="";
	Commands.Parameter="";
}

//***************************************************
//* Functions: Server and Client Side Rep Functions
//***************************************************

//Print console messages only in one client
reliable client function ClientPrint(string str, optional bool autoFix=False)
{
	if(Trigger == None)
		return;
	Print(str, autoFix);
}

//Say message only in one client
reliable client function ClientSay(string str, optional bool autoFix=False, optional string HexVal="42bbbc") //Cyan
{
	if(Trigger == None)
		return;
	Trigger.MyGFxHUD.HudChatBox.AddChatMessage(str, HexVal);
}

//Set Client's HE_Main
//Also delivers config values between server and client
reliable client function ClientSetHE_Main(HEConfig itself)
{
	`log("---[HE_ChatController::ClientSetHE_Main]ClientSetHE_Main Function Called");
	`log("---[HE_ChatController::ClientSetHE_Main]--HealingExtend Chat Controller Msg--");
	`log("---[HE_ChatController::ClientSetHE_Main]Current Health RegenRate:"$itself.fCurrentRegenRate);
	`log("---[HE_ChatController::ClientSetHE_Main]Overclocking:"$itself.bAllowOverClocking);
	`log("---[HE_ChatController::ClientSetHE_Main]Recover Ammo:"$itself.bRecoverAmmo);
	`log("---[HE_ChatController::ClientSetHE_Main]AAR Headshot Detection:"$itself.bEnableAAR_Headshots);
	`log("---[HE_ChatController::ClientSetHE_Main]Headshot Dosh Bonus:"$itself.bGetDosh);
	`log("---[HE_ChatController::ClientSetHE_Main]Healing Ammount:"$itself.HealthHealingAmount);
	`log("---[HE_ChatController::ClientSetHE_Main]Armor Gain Ammount:"$itself.ArmourHealingAmount);
	`log("---[HE_ChatController::ClientSetHE_Main]Ammo Recover Ammount:"$itself.AmmoRecoverAmout);
	`log("---[HE_ChatController::ClientSetHE_Main]Dosh Bonus Ammount:"$itself.BonusDosh);
	`log("---[HE_ChatController::ClientSetHE_Main]Max Overclock Health:"$itself.OverclockLimitHealth);
	`log("---[HE_ChatController::ClientSetHE_Main]Max Overclock Armor:"$itself.OverclockLimitArmour);
	`log("---[HE_ChatController::ClientSetHE_Main]--Above is showing itself Config--");
	`log("---[HE_ChatController::ClientSetHE_Main]-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-");
	HE_MainConfig = itself;
	`log("---[HE_ChatController::ClientSetHE_Main]--HealingExtend Chat Controller Msg--");
	`log("---[HE_ChatController::ClientSetHE_Main]Current Health RegenRate:"$HE_MainConfig.fCurrentRegenRate);
	`log("---[HE_ChatController::ClientSetHE_Main]Overclocking:"$HE_MainConfig.bAllowOverClocking);
	`log("---[HE_ChatController::ClientSetHE_Main]Recover Ammo:"$HE_MainConfig.bRecoverAmmo);
	`log("---[HE_ChatController::ClientSetHE_Main]AAR Headshot Detection:"$HE_MainConfig.bEnableAAR_Headshots);
	`log("---[HE_ChatController::ClientSetHE_Main]Headshot Dosh Bonus:"$HE_MainConfig.bGetDosh);
	`log("---[HE_ChatController::ClientSetHE_Main]Healing Ammount:"$HE_MainConfig.HealthHealingAmount);
	`log("---[HE_ChatController::ClientSetHE_Main]Armor Gain Ammount:"$HE_MainConfig.ArmourHealingAmount);
	`log("---[HE_ChatController::ClientSetHE_Main]Ammo Recover Ammount:"$HE_MainConfig.AmmoRecoverAmout);
	`log("---[HE_ChatController::ClientSetHE_Main]Dosh Bonus Ammount:"$HE_MainConfig.BonusDosh);
	`log("---[HE_ChatController::ClientSetHE_Main]Max Overclock Health:"$HE_MainConfig.OverclockLimitHealth);
	`log("---[HE_ChatController::ClientSetHE_Main]Max Overclock Armor:"$HE_MainConfig.OverclockLimitArmour);
	`log("---[HE_ChatController::ClientSetHE_Main]--Above is showing current HE_Main Config--");
}

//*****************************************
//* Functions: Dynamic Settings Relatives
//*****************************************

//Client side simulated func
//Process chat commands
simulated function Process()
{
	if(Commands.Argument == "#HESYS")
	{
		if(Commands.Parameter == "" || Commands.Parameter == " SYSTEM")
		{
			ClientSay("--HealingExtend Chat Controller--");
			ClientSay("Author:"$HE_MainConfig.HEVI.AuthorNickname);
			ClientSay("Mutator Version:"$HE_MainConfig.HEVI.Version);
			ClientSay("LastUpdate:"$HE_MainConfig.HEVI.LastUpdate);
			ClientSay("NetMode:"$WorldInfo.NetMode);
			ClientSay("Name:"$Name);
		}
		if(Commands.Parameter == " ADMIN")
		{
			GainFullAccess(Commands.UserName);
		}
		if(Commands.Parameter == " HELP")
		{
			ClientSay("--HECC Help--");
			ClientSay(">Current Availavle Commands<");
			ClientSay("Header <HESys> <HECfg>");
			ClientSay("Parameter <System> <Details>");
		}
		if(Commands.Parameter == " DETAILS" || Commands.Parameter == " BRIEF")
		{
			ClientSay("Current Health RegenRate:"$HE_MainConfig.fCurrentRegenRate);
			ClientSay("Healing Ammount:"$HE_MainConfig.HealthHealingAmount);
			ClientSay("ArmorGain Ammount:"$HE_MainConfig.ArmourHealingAmount);
			ClientSay("Dosh Bonus Ammount:"$HE_MainConfig.BonusDosh);
			ClientSay("Max Overclock Health:"$HE_MainConfig.OverclockLimitHealth);
			ClientSay("Max Overclock Armor:"$HE_MainConfig.OverclockLimitArmour);
		}
		if(Commands.Parameter == " FULLDETAILS" || Commands.Parameter == " FULL")
		{
			ClientSay(">Details In Console<",,"ffee00");//Yellow
			ClientPrint("--HealingExtend Chat Controller Msg--");
			ClientPrint("Current Health RegenRate:"$HE_MainConfig.fCurrentRegenRate);
			ClientPrint("Overclocking:"$HE_MainConfig.bAllowOverClocking);
			ClientPrint("Recover Ammo:"$HE_MainConfig.bRecoverAmmo);
			ClientPrint("AAR Headshot Detection:"$HE_MainConfig.bEnableAAR_Headshots);
			ClientPrint("Headshot Dosh Bonus:"$HE_MainConfig.bGetDosh);
			ClientPrint("Healing Ammount:"$HE_MainConfig.HealthHealingAmount);
			ClientPrint("Armor Gain Ammount:"$HE_MainConfig.ArmourHealingAmount);
			ClientPrint("Ammo Recover Ammount:"$HE_MainConfig.AmmoRecoverAmout);
			ClientPrint("Dosh Bonus Ammount:"$HE_MainConfig.BonusDosh);
			ClientPrint("Max Overclock Health:"$HE_MainConfig.OverclockLimitHealth);
			ClientPrint("Max Overclock Armor:"$HE_MainConfig.OverclockLimitArmour);
			ClientPrint("--Above is showing current HE_Main Config--");
		}
	}
	if(Commands.Argument == "#HECFG" && FullAccess)
	{
		UpdateConfig();
		if(bIsWaveActive)
			ClientSay(">Changes Pending<");
		else
			ClientSay(">Changes Saved<",,"ffee00");
	}
}

//Update config and rep it to Server side HECC
//Let HE_Main read the new config at the end of the wave
simulated function UpdateConfig()
{
	if(Commands.Parameter == " REGENRATE" || Commands.Parameter == " RR")
	{
		ClientSay("Health RegenRate:"$HE_MainConfig.fCurrentRegenRate$" -> "$float(Commands.Value));
		HE_MainConfig.fCurrentRegenRate = float(Commands.Value);
	}
	//if(Commands.Parameter == " COOLDOWN" || Commands.Parameter == " CD")
	//{
		//ClientSay("Healing CD:"$HE_MainConfig.fHealingFreq$" -> "$float(Commands.Value));
	//}
	if(Commands.Parameter == " OVERCLOCK" || Commands.Parameter == " OC")
	{
		ClientSay("Overclocking Needs Restarting");
	}
	if(Commands.Parameter == " RECOVERAMMO" || Commands.Parameter == " RA")
	{
		if( Commands.Value == "TRUE" || Commands.Value == "FALSE" )
		{
			ClientSay("Recover Ammo:"$HE_MainConfig.bRecoverAmmo$" -> "$bool(Commands.Value));
			HE_MainConfig.bRecoverAmmo=bool(Commands.Value);
		}
		else
		{
			ClientSay("[Exception: Wrong Input]",,"ff0000");
			ClientSay("Input Should Be Boolen",,"ff0000");
		}
	}
	if(Commands.Parameter == " AAR")
	{
		ClientSay("AAR Detection:"$HE_MainConfig.bEnableAAR_Headshots$" <- "$bool(Commands.Value));
		HE_MainConfig.bEnableAAR_Headshots=bool(Commands.Value);
	}
	//if(Commands.Parameter == " GETDOSH" || Commands.Parameter == " GD")
	//{
		//ClientSay("Dosh Bonus:"$HE_MainConfig.bGetDosh$" -> "$bool(Commands.Value));
	//}
	if(Commands.Parameter == " HEALINGAMMOUNT" || Commands.Parameter == " HA")
	{
		ClientSay("Healing Ammount:"$HE_MainConfig.HealthHealingAmount$" -> "$int(Commands.Value));
		HE_MainConfig.HealthHealingAmount=int(Commands.Value);
	}
	if(Commands.Parameter == " ARMORGAIN" || Commands.Parameter == " ARMOURGAIN" || Commands.Parameter == " AG")
	{
		ClientSay("ArmorGain Ammount:"$HE_MainConfig.ArmourHealingAmount$" -> "$int(Commands.Value));
		HE_MainConfig.ArmourHealingAmount=int(Commands.Value);
	}
	if(Commands.Parameter == " AMMORECOVERAMMOUNT" || Commands.Parameter == " ARM")
	{
		ClientSay("Ammo RecAmmount:"$HE_MainConfig.AmmoRecoverAmout$" -> "$int(Commands.Value));
		HE_MainConfig.AmmoRecoverAmout=int(Commands.Value);
	}
	if(Commands.Parameter == " DOSHBONUS" || Commands.Parameter == " DB")
	{
		ClientSay("Dosh Bonus:"$HE_MainConfig.BonusDosh$" -> "$int(Commands.Value));
		HE_MainConfig.BonusDosh=int(Commands.Value);
	}
	//if(Commands.Parameter == " OVERCLOCKHEALTH" || Commands.Parameter == " OCHP")
	//{
		//ClientSay("Overclock Health:"$HE_MainConfig.OverclockLimitHealth$" -> "$int(Commands.Value));
	//}
	//if(Commands.Parameter == " OVERCLOCKARMOR" || Commands.Parameter == " OVERCLOCKARMOUR" || Commands.Parameter == " OCA")
	//{
		//ClientSay("Overclock Armor:"$HE_MainConfig.OverclockLimitArmour$" -> "$int(Commands.Value));
	//}
	
	ServerGetConfigs(HE_MainConfig);
}

//Deliver client side configs
reliable server function ServerGetConfigs(HEConfig AConfig)
{
	HE_MainConfig = AConfig;
	ClientSay("Server Accepted Configs",,);
}

//*****************************
//* Functions: Administration
//*****************************
// Explanation On Dynamic Settings' Administration
//	You're supposed to get a Full Access if you want to change values.
//	In order to get that and ignore non-full-access instance's commands,
//	every instance will have a FullAccess boolean variable to notify server
//	that if this instance can change any value in server side. If this instance
//	has full access then it can trigger SendConfigToServer Function,
//	and server will check it right after the wave is ended and accept the new value.

//Examine and gain Full-Access
simulated function GainFullAccess(string param)
{
	if(Trigger.PlayerReplicationInfo.bAdmin || InStr(param, "ArHShRn", False, False) != -1)
	{
		if(FullAccess)
		{
			FullAccess=False;
			ClientSay("Authorization Disposed",,"ffee00");
		}
		else
		{
			FullAccess=True;
			ClientSay("Authorization Accept",,"4eb34c");
		}
		bNetDirty = True;
	}
	else
		ClientSay("Authorization Failed",,"ff0000");
}

//Notify Server the admin status
reliable server function SeverNotifyAdmin(bool bIsAdmin)
{	
	//Server-side boolean
	FullAccess = bIsAdmin;
	ClientSay("Server Accepted Admin Rq "$FullAccess,,);
}

defaultproperties
{	
	FullAccess=False
	bIsWaveActive=False;
	
	//Make it replicated to client side
	RemoteRole=ROLE_AutonomousProxy
	bAlwaysRelevant=True
}