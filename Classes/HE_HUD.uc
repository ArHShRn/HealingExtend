class HE_HUD extends KFGFxHudWrapper;

//*********************************************************
//* Variables
//*********************************************************
var KFProfileSettings Profile;
//*********************************************************
//* Configs
//*********************************************************
var bool bDrawDebug;
var float LastX,LastY,StartX,StartY;

//*********************************************************
//* Initialization
//*********************************************************
replication
{
	if(Role == Role_Authority)
		Profile;
}

//Completely Override super PostBeginPlay
simulated function PostBeginPlay()
{	
	//First. log roles to debug
	`log("[HE_HUD:"$WorldInfo.NetMode$"]This HUD Role="$Role);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]This HUD RemoteRole="$RemoteRole);
	
	//HUD PostBeginPlay
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Const Owner="$Owner.Name);
	PlayerOwner = PlayerController(Owner);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Set PlayerOwner to "$PlayerOwner.Name);
	
	// e.g. getting material pointers to control effects for gameplay
	NotifyBindPostProcessEffects();
	
	//KFHUDBase PostBeginPlay
	bDrawCrosshair = class'KFGameEngine'.static.IsCrosshairEnabled();
	bCachedShowOverlays = bShowOverlays;
	
	KFPlayerOwner = KFPlayerController(PlayerOwner);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Set KFPlayerOwner to "$KFPlayerOwner.Name);
	if( KFPlayerOwner != none && KFPlayerOwner.OnlineSub != none )
	{
		`log("[HE_HUD:"$WorldInfo.NetMode$"]Entered Profile get process.");
		`log("[HE_HUD:"$WorldInfo.NetMode$"]Start getting local player profile...");
		//If it's Standalone SOLO or Client Side
		if((Role == Role_Authority && WorldInfo.NetMode == NM_Standalone) || (Role < Role_Authority && WorldInfo.NetMode == NM_Client))
			Profile = KFProfileSettings(KFPlayerOwner.OnlineSub.PlayerInterface.GetProfileSettings( LocalPlayer(PlayerOwner.Player).ControllerId ));
		//If it's Server Side
		else if(Role == Role_Authority && WorldInfo.NetMode != NM_Standalone)
			ClientGetLocalPlayerProfile();
		if(Profile==None)
		{
			`log("[HE_HUD:"$WorldInfo.NetMode$"]Warning: Profile is none ! Set Scale to default !");
			FriendlyHudScale=1.0f;
			return;
		}
		FriendlyHudScale = Profile.GetProfileFloat( KFID_FriendlyHudScale );
		//Clamping the value here in case we receive some crazy number
		FClamp( FriendlyHudScale, 0.25, 1.f);
	}
}

reliable client function ClientGetLocalPlayerProfile()
{
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Entered: Get Local Player Profile...");
	if(LocalPlayer(PlayerOwner.Player)==None)
	{
		`log("[HE_HUD:"$WorldInfo.NetMode$"]Error Getting Local Player...");
		return;
	}
	Profile = KFProfileSettings(KFPlayerOwner.OnlineSub.PlayerInterface.GetProfileSettings( LocalPlayer(PlayerOwner.Player).ControllerId ));
	RepProfileToServer();
}

reliable server function RepProfileToServer()
{
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Rep Profile To Server...");
	Profile=self.Profile;
}

simulated function CreateHUDMovie(optional bool bForce)
{
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Creating a new HUDMovie Player HUD");
	
	ClientPrintTest();
	ServerPrintTest();
	super.CreateHUDMovie(bForce);
}
//*********************************************************
//* Misc
//*********************************************************
simulated function Print( string message, optional bool autoPrefix = true )
{
	local GameViewportClient LocalGVC;

	if ( autoPrefix )
	{
		message = "[HE_HUD:"$WorldInfo.NetMode$"] "$message;
	}

	LocalGVC = class'GameEngine'.static.GetEngine().GameViewport;

	if ( LocalGVC != None )
	{
		LocalGVC.ViewportConsole.OutputTextLine(message);
	}
}

exec function HEDrawDebug()
{
	bDrawDebug=!bDrawDebug;
	Print("Enable Debug Draw");
}
//*********************************************************
//* Tests
//*********************************************************
reliable client function ClientPrintTest()
{
	`log("[HE_HUD]Exec ClientPrintTest"); 
	Print("ClientPrintTest");
}

reliable server function ServerPrintTest()
{
	`log("[HE_HUD]Exec ServerPrintTest"); 
	Print("ServerPrintTest");
}

//*********************************************************
//* Render Main
//*********************************************************
simulated function DrawHUD()
{
	super.DrawHUD();
	DrawHE_Main(StartX, StartY, LastX, LastY);
	if(bDrawDebug)
		DrawDebug(LastX, LastY);
}

simulated function DrawDebug(float X, float Y, optional out float LastLX, optional out float LastLY)
{
	local float LX, LY;
	Canvas.SetDrawColor(255, 192, 203); //Pink
	
	Canvas.SetPos(X, Y);
	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.StrLen("---Healing Extend HUD Debug Info Inner---", LX, LY);
	LastLY=Y+LY;
	LastLX=X;

	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   ThisHUD="$self.Name,, 1.0f, 1.0f);
	LastLY=LastLY+LY;

	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   ThisHUD.Role="$self.Role,, 1.0f, 1.0f);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   ThisHUD.RemoteRole="$self.RemoteRole,, 1.0f, 1.0f);
	LastLY=LastLY+LY;

	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   Owner="$Owner.Name,, 1.0f, 1.0f);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   Owner.Role="$Owner.Role,, 1.0f, 1.0f);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   Owner.RemoteRole="$Owner.RemoteRole,, 1.0f, 1.0f);
	LastLY=LastLY+LY;
}

simulated function DrawHE_Main(float X, float Y, optional out float LastLX, optional out float LastLY)
{
	local float LX, LY;
	Canvas.SetDrawColor(255, 255, 0); //Yellow
	
	Canvas.SetPos(X, Y);
	Canvas.DrawText("---Healing Extend HUD Info---",, 1.0f, 1.0f);
	Canvas.StrLen("---Healing Extend HUD Info---", LX, LY);
	LastLY=Y+LY;
	LastLX=X;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText(" _>"$WorldInfo.NetMode,, 1.0f, 1.0f);
	LastLY=LastLY+LY;

	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText(" _>Current Player:"$KFPlayerOwner.PlayerReplicationInfo.PlayerName,, 1.0f, 1.0f);
	LastLY=LastLY+LY;
}

defaultproperties
{
	StartX=50.0f
	StartY=200.0f
	bDrawDebug=False;
	
	RemoteRole=Role_SimulatedProxy;
}