class HE_HUD extends KFGFxHudWrapper;
	
//-----------------------------------------------------------------
//Configs
//-----------------------------------------------------------------
var KFPlayerController			KFPC;

var bool isEnteredCreateHUDMovie;
var bool bDrawDebug;
var float LastX,LastY;

//-----------------------------------------------------------------
//Initialization
//-----------------------------------------------------------------
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetServerKFPC_myHUD();
}
//-----------------------------------------------------------------
//Render Main
//-----------------------------------------------------------------
function CreateHUDMovie(optional bool bForce)
{
	//Log Role
	if(Role < Role_Authority)
		`log("[HE_HUD:Client]Client Role:"$Role);
	if(Role == Role_Authority)
		`log("[HE_HUD:Server]Server Role:"$Role);
		
	isEnteredCreateHUDMovie=True;
	`log("[HE_HUD:Client]Creating a new HUDMovie Player HUD");
	super.CreateHUDMovie(bForce);
}

reliable server function SetServerKFPC_myHUD()
{
	KFPlayerOwner.myHUD=self;
	`log("[HE_HUD:Server]KFPlayerOwner HUD sets to: "$KFPlayerOwner.myHUD.Name);
}

exec function HEDrawDebug()
{
	bDrawDebug=!bDrawDebug;
}

function DrawDebug(float X, float Y, optional out float LastLX, optional out float LastLY)
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
	Canvas.DrawText("   ThisHUD="$self.Name);
	LastLY=LastLY+LY;

	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   Owner="$Owner.Name);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   ENetRole="$Role);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   ENetRemoteRole="$RemoteRole);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Debug Info Inner---");
	Canvas.DrawText("   bNetOwner="$bNetOwner);
	LastLY=LastLY+LY;
}

function DrawHE_RecoverInfo(optional out float LastLX, optional out float LastLY)
{
	local float LX, LY;
	LastLX=50.0f;
	LastLY=250.0f;
	Canvas.SetDrawColor(255, 255, 0); //Yellow
	
	Canvas.SetPos(LastLX, LastLY);
	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.StrLen("---Healing Extend HUD Info---", LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   Headshots AAR:"$Int(KFPlayerOwner.PWRI.VectData1.X));
	Canvas.StrLen("   Headshots AAR:"$Int(KFPlayerOwner.PWRI.VectData1.X), LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   LargeZeds Kills:"$Int(KFPlayerOwner.PWRI.LargeZedKills));
	Canvas.StrLen("   LargeZeds Kills:"$Int(KFPlayerOwner.PWRI.LargeZedKills), LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   Healing Ammount:"$Int(KFPlayerOwner.PWRI.VectData2.Z));
	Canvas.StrLen("   Healing Ammount:"$Int(KFPlayerOwner.PWRI.VectData2.Z), LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   Healing Received:"$Int(KFPlayerOwner.PWRI.VectData2.Y));
	Canvas.StrLen("   Healing Received:"$Int(KFPlayerOwner.PWRI.VectData2.Y), LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   Damage Give-out:"$Int(KFPlayerOwner.PWRI.VectData1.Z));
	Canvas.StrLen("   Damage Give-out:"$Int(KFPlayerOwner.PWRI.VectData1.Z), LX, LY);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText("   Damage Taken:"$Int(KFPlayerOwner.PWRI.VectData2.X));
	Canvas.StrLen("   Damage Taken:"$Int(KFPlayerOwner.PWRI.VectData2.X), LX, LY);
	LastLY=LastLY+LY;
}

Event DrawHUD()
{
	super.DrawHUD();
	DrawHE_RecoverInfo(LastX, LastY);
	if(bDrawDebug)
		DrawDebug(LastX, LastY);
}

defaultproperties
{
	isEnteredCreateHUDMovie=False;
	bDrawDebug=False;
}