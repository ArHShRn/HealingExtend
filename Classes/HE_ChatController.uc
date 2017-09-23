class HE_ChatController extends Actor
	DependsOn(HE_Datastructure)
	Config(HE_ChatController);
	
//*********************************************************
//* Variables
//*********************************************************
var GameViewportClient			LocalGVC;
var Console						LocalC;
var HECommand					Commands;

var HE_Main						HE_MainConfig;
var KFPlayerController			KFPlayerOwner;
var KFPlayerInput				KFPI;

var name						KeyBindName;

//*********************************************************
//* Initialization
//*********************************************************
simulated function PreBeginPlay()
{
	super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
	//Get KFPlayerOwner
	GetKFPC();
	
	//Log to debug
	LogStatus();
	
	//Init player input
	KeyBindName='F1';
	KFPI=KFPlayerInput( KFPlayerOwner.PlayerInput );
	if(KFPI == None)
		`log("[HE_ChatController:"$WorldInfo.NetMode$"]Warning: Fail to init KFPI!");
	//Set Bind
	else
		KFPI.SetBind(KeyBindName, "say #HESys&Details");
	
	//Get LocalGVC to search for the player chat messages
	`log("[HE_ChatController:"$WorldInfo.NetMode$"] Initializing Local Game View Port");
	LocalGVC=class'GameEngine'.static.GetEngine().GameViewport;
	if(LocalGVC != None)
	{
		LocalC = LocalGVC.ViewportConsole;
		if(LocalC != None)
			`log("[HE_ChatController:"$WorldInfo.NetMode$"] Get a local console.");
	}
	else
		`log("[HE_ChatController:"$WorldInfo.NetMode$"] Error getting a local console!");
	
	`log("[HE_ChatController:"$WorldInfo.NetMode$"]End PostBeginPlay");
	super.PostBeginPlay();	

	Print("--HE Chat Controller Initialization Status As Following--", False);
	Print("Current Role="$Role, False);
	Print("Current RemoteRole="$RemoteRole, False);
	Print("Current Owner="$Owner, False);
	Print("--HE Chat Controller Initialization Result As Following--", False);
	Print("-I should print this twice to be successfully initialized-", False);
	Print(GetChatMessage(), False);
}

simulated function LogStatus()
{
	`log("[HE_ChatController:"$Worldinfo.NetMode$"]Current Role="$Role);
	`log("[HE_ChatController:"$Worldinfo.NetMode$"]Current RemoteRole="$RemoteRole);
	`log("[HE_ChatController:"$Worldinfo.NetMode$"]Current Owner="$Owner);
}

reliable client function ClientSetHE_Main(HE_Main itself)
{
	HE_MainConfig = itself;
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
	local LocalPlayer LocalPlayerOwner;

	LocalPlayerOwner = class'Engine'.static.GetEngine().GamePlayers[0];
	if (LocalPlayerOwner == none)
	{
		`log("[HE_ChatController:"$Worldinfo.NetMode$"]WARNING: Find NONE LocalPlayer !");
		return none;
	}
	`log("[HE_ChatController:"$Worldinfo.NetMode$"]Return LocalPlayer.Actor "$LocalPlayerOwner.Actor);
	return LocalPlayerOwner.Actor;
}

//To get KFPlayerOwner
//Attention: KFPlayerController is only created after ModifyPlayer!
//So should be the HUD !
simulated function GetKFPC()
{
	KFPlayerOwner = KFPlayerController( GetLPPC() );
	if(KFPlayerOwner == None)
	{
		`log("[HE_ChatController:"$Worldinfo.NetMode$"]WARNING: Get no KFPlayerOwner !");
		return;
	}
}
//*********************************************************
//* Tests
//*********************************************************

//*********************************************************
//* Functions
//*********************************************************
//Get chat messages from console
simulated function string GetChatMessage(optional out int isNone)
{
	local string ConsoleString;
	isNone = 0;
	//Get a string from the head of console lines
	if(LocalGVC == None || LocalC == None)
	{
		ConsoleString = "Error: Can't Find Any Local GameViewPort Or Console!";
		isNone=1;
	}
	else
		ConsoleString = LocalC.Scrollback[LocalC.SBHead];
	
	return ConsoleString;
}

//Print sth in console
simulated function Print( string message, optional bool autoPrefix = true )
{
	if ( autoPrefix )
	{
		message = "[HE_HUD:"$WorldInfo.NetMode$"] "$message;
	}

	if ( LocalGVC != None )
	{
		LocalGVC.ViewportConsole.OutputTextLine(message);
	}
}

//Check get status
simulated function bool CheckAndGetPlayerChat()
{
	local string ConsoleString;
	local int isNone;
	ConsoleString = GetChatMessage(isNone);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]ConsoleString = GetChatMessage(isNone) = "$ConsoleString);
	
	if(isNone==1)
		return False;
	
	if(ParsingCommand(ConsoleString))
		return True;
	
	return False;
}

//Parsing commands into HECommand structure
simulated function bool ParsingCommand(string str)
{
	local string tmp, tmpSay;
	local int space, header;
	
	//Get the command a right format
	tmp = Right(str, Len(str) - 4);
	tmp = Left(tmp, Len(tmp) - 4);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]tmp = "$tmp);
	//Search for Say
	tmpSay = Left(tmp, 3);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]tmpSay = "$tmpSay);
	if(tmpSay != "Say" && tmpSay !="say" && tmpSay!="SAY")
		return False;
	
	//Trim command out of "Say ", left command's structure	
	tmp = Right(tmp, Len(tmp) - 4);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]tmp = Right(str, Len(str) - 4) = "$tmp);
	
	//Search for command identification
	header = InStr(tmp, "#HE", False, True,);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]header = InStr(tmp, #HE, False, True,) = "$header);
	if(header == -1)
		return False;
	//Search for space to trim
	space = InStr(tmp, "&", False, True,);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]space = InStr(tmp, &, False, True,) = "$space);
	if(space == -1)
		return False;
	
	//Parsing commands
	Commands.CommandHead = "#HE";
	Commands.Argument = Left(tmp, space);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]Commands.Argument = Left(tmp, space - 1) = "$Commands.Argument);
	Commands.Parameter = Right(tmp, Len(tmp) - space - 1);
	//`log("[HE_ChatController:"$Worldinfo.NetMode$"]Commands.Parameter = Right(tmp, Len(tmp) - space) = "$Commands.Parameter);
	return True;
}

//Notify that reading is complete
reliable client function Complete()
{
	//If failed to finish reading commands
	if(!CheckAndGetPlayerChat())
		return;
	
	Print("-Reading complete-", False);
	Print("Command:"$Commands.Argument, False);
	Print("Parameter:"$Commands.Parameter, False);
	Process();
	
	
	Commands.CommandHead="";
	Commands.Argument="";
	Commands.Parameter="";
}

simulated function Process()
{
	if(Commands.Argument == "#HESys")
	{
		if(Commands.Parameter == "Details")
		{
			PrintForAll("--Healing Extend Mutator Config Values--");
			PrintForAll("Current Health RegenRate:"$HE_MainConfig.fCurrentRegenRate);
			PrintForAll("Current Healing Cooling Down:"$HE_MainConfig.fHealingFreq);
			PrintForAll("Overclocking:"$HE_MainConfig.bAllowOverClocking);
			PrintForAll("Recover Ammo:"$HE_MainConfig.bRecoverAmmo);
			PrintForAll("AAR Headshot Detection:"$HE_MainConfig.bEnableAAR_Headshots);
			PrintForAll("Headshot Dosh Bonus:"$HE_MainConfig.bGetDosh);
			PrintForAll("Healing Ammount:"$HE_MainConfig.HealthHealingAmount);
			PrintForAll("Armor Gain Ammount:"$HE_MainConfig.ArmourHealingAmount);
			PrintForAll("Ammo Recover Ammount:"$HE_MainConfig.AmmoRecoverAmout);
			PrintForAll("Dosh Bonus Ammount:"$HE_MainConfig.BonusDosh);
			PrintForAll("Max Overclock Health:"$HE_MainConfig.OverclockLimitHealth);
			PrintForAll("Max Overclock Armor:"$HE_MainConfig.OverclockLimitArmour);
			SayForAll("Current Health RegenRate:"$HE_MainConfig.fCurrentRegenRate);
			SayForAll("Current Healing Cooling Down:"$HE_MainConfig.fHealingFreq);
			SayForAll("Overclocking:"$HE_MainConfig.bAllowOverClocking);
			SayForAll("Recover Ammo:"$HE_MainConfig.bRecoverAmmo);
			SayForAll("AAR Headshot Detection:"$HE_MainConfig.bEnableAAR_Headshots);
			SayForAll("Headshot Dosh Bonus:"$HE_MainConfig.bGetDosh);
			SayForAll("Healing Ammount:"$HE_MainConfig.HealthHealingAmount);
			SayForAll("Armor Gain Ammount:"$HE_MainConfig.ArmourHealingAmount);
			SayForAll("Ammo Recover Ammount:"$HE_MainConfig.AmmoRecoverAmout);
			SayForAll("Dosh Bonus Ammount:"$HE_MainConfig.BonusDosh);
			SayForAll("Max Overclock Health:"$HE_MainConfig.OverclockLimitHealth);
			SayForAll("Max Overclock Armor:"$HE_MainConfig.OverclockLimitArmour);
		}
	}
	if(Commands.Argument == "#HEConfig")
	{
		//To-do
		SayForAll("Function Under Construction");
	}
}

reliable server function PrintForAll(string str, optional bool autoFix=False)
{
	local HE_ChatController instance;
	ForEach WorldInfo.AllActors(class'HE_ChatController', instance)
	{
		instance.ClientPrint(str, autoFix);
	}
}

reliable server function SayForAll(string str, optional bool autoFix=False)
{
	local KFPlayerController KFPC;
	ForEach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		KFPC.MyGFxHUD.HudChatBox.AddChatMessage(str, class 'KFLocalMessage'.default.EventColor);
	}
}

reliable client function ClientPrint(string str, bool autoFix)
{
	Print(str, autoFix);
}

defaultproperties
{
	//Make it replicated to client side
	RemoteRole=ROLE_SimulatedProxy
}