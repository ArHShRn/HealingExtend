//=============================================================================
// Healing Extend Mutator : Healing Extend(HE) HUD Base Class
// This class is the base class of the HE mut's HUD
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version 0.1.3
// Last Update Date Aug.5th 2017
//=============================================================================
class HE_HUDBase extends KFGFxHudWrapper
	DependsOn(HE_DataStructure)
	Config(HealingExtend);

//*********************************************************
//* Variables
//*********************************************************
var float				LastX,LastY,StartX,StartY;
var bool				bDrawDebug;
var bool				bDrawDebugPI;
var bool				bASSAim;
var bool				bIsPlayerDead;

var bool				bDrawEnergyBar;

var bool				bPlayerPressedQ;
var bool				bDrawSkillMsg;
var string				SkillNotification;

var bool				EnergyTextFlag;
var bool				EnergyTextFlagTimerFlag;

var float				ScreenX, ScreenY;
var float				PresetX, PresetY;
var float				EnergyBarPercent;

var int					Default_HurtHealthRateNotify;
var int					Default_CriticalHealthRateNotify;

var HUDCrosshairStatus	HECS;
var AsCMode				CSMode;

var color				Default_MainHUDColor;
var color				Default_DebugHUDColor;
var color				Default_CrosshairColor;
var color				Default_OverclockedHealthColor;
var color				Default_OverclockedArmorColor;
var color				Default_LowSeverityColor;
var color				Default_CriticalSeverityColor;
var color				Default_EnergyBarColor;

//*********************************************************
//* Configs
//*********************************************************
var config bool			bInitedConfig;
var config float		ASSAim_Length;
var config float		ASSAim_Space;
var config float		ASSAim_Width;
var config float		HUDMainTextScale;
var config float		HUDDebugTextScale;

var config int			HurtHealthRateNotify;
var config int			CriticalHealthRateNotify;			

var config color		MainHUDColor;
var config color		DebugHUDColor;
var config color		CrosshairColor;
var config color		OverclockedHealthColor;
var config color		OverclockedArmorColor;
var config color		LowSeverityColor;
var config color		CriticalSeverityColor;
var config color		EnergyBarColor;

//*********************************************************
//* Initialization
//*********************************************************
Event PreBeginPlay()
{
	//Force init in client or it will fail to work
	//Disadvantage: Player would not change the color themselves
	InitBasicValues();
	SaveConfig();
	super.PreBeginPlay();
}

simulated function PostBeginPlay()
{	
	//First. log roles to debug
	`log("[HE_HUD:"$WorldInfo.NetMode$"]Spawn a new HUD name="$Name$" Owner="$Owner);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]This HUD Role="$Role);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]This HUD RemoteRole="$RemoteRole);
	`log("[HE_HUD:"$WorldInfo.NetMode$"]This HUD bNetOwner="$bNetOwner);
	
	super.PostBeginPlay();
}

function InitBasicValues()
{
	bInitedConfig=True;
	ASSAim_Width=3.0f;
	ASSAim_Length=8.0f;
	ASSAim_Space=4.0f;
	HUDMainTextScale=1.0f;
	HUDDebugTextScale=1.0f;
	
	HurtHealthRateNotify=Default_HurtHealthRateNotify;
	CriticalHealthRateNotify=Default_CriticalHealthRateNotify;
	
	bShowHUD=True;
	
	MainHUDColor=Default_MainHUDColor; //Yellow
	DebugHUDColor=Default_DebugHUDColor; //Pink
	CrosshairColor=Default_CrosshairColor; //Red
	OverclockedArmorColor=Default_OverclockedArmorColor; //Sea Green 2
	OverclockedHealthColor=Default_OverclockedHealthColor; //Original blue
	LowSeverityColor=Default_LowSeverityColor; //Yellow
	CriticalSeverityColor=Default_CriticalSeverityColor; //Red
	EnergyBarColor=Default_EnergyBarColor; //Bg Color !!!!!!!
	
}
//*********************************************************
//* Misc
//*********************************************************

//A function by Blackout's CD
//Print sth in console
function Print( string message, optional bool autoPrefix = true )
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

//Set EnergyTextFlag to simulate the anim of flash
simulated function SetEnergyTextFlag()
{
	EnergyTextFlag=!EnergyTextFlag;
}

//Final skill
simulated function FinalSkill()
{
	Print("Triggered Final Skill!");
}

//Draw skill used notify
simulated function DrawSkillMsg(string Msg, optional int MsgLifTime=5)
{
	bDrawSkillMsg=True;
	
	SkillNotification=Msg;
	
	SetTimer(MsgLifTime, False, 'ClearDrawSkillMsgFlag');
}

//Clear global msg notification
simulated function ClearDrawSkillMsgFlag()
{
	bDrawSkillMsg=False;
}

//*********************************************************
//* Exec
//*********************************************************

//Console command to toggle draw debug info
exec function HEDrawDebug()
{
	bDrawDebug=!bDrawDebug;
	if(bDrawDebug)
		Print("Enable Debug Draw");
	else
		Print("Disable Debug Draw");
}

//Console command to toggole draw debug PI
exec function HEDrawDebugPI()
{
	bDrawDebugPI=!bDrawDebugPI;
	if(bDrawDebugPI)
		Print("Enable Debug PI Draw");
	else
		Print("Disable Debug PI Draw");
}

//Console command to toggle AsC
exec function ToggleAsC()
{
	bASSAim=!bASSAim;
	if(bASSAim)
	{
		Print("Enable Crosshair Draw");
	}
	else
	{
		Print("Close Crosshair Draw");
	}	
}

//Console command CHN pinyin to toggle AsC
exec function ZhunXin()
{
	ToggleAsC();
}

//Console command to change AsC draw mode
exec function ChangeAsCMode()
{
	if(CSMode==AsC_Default)
	{
		CSMode=AsC_CenterDot;
		Print("Enable CenterDot AsC");
	}
	else if(CSMode==AsC_CenterDot)
	{
		CSMode=AsC_OnlyDot;
		Print("Enable OnlyDot AsC");
	}
	else if(CSMode==AsC_OnlyDot)
	{
		CSMode=AsC_Default;
		Print("Enable Default AsC");
	}
}

//Console command CHN to change AsC draw mode
exec function HuanZhunXin()
{
	ChangeAsCMode();
}

exec function SetDebugEnergyBarPercent(float aNumber)
{
	EnergyBarPercent=aNumber;
}

exec function FangDaZhao()
{
	bPlayerPressedQ=True;
}

//---------------------Subclass Interfaces------------------------
exec function TriggerFinalSkill()
{
	EnergyBarPercent=0.f;
	FinalSkill();
}
exec function TriggerOptionalSkill();

//*********************************************************
//* Tests
//*********************************************************

//Same as DrawFriendlyHumanPlayerInfo but its pos is at Center screen
//And its pawn is yourself
//Copy code here at any change of the original code!!!!!!!!!!!!
simulated function bool DrawDebugHumanPlayerInfo()
{
	local KFPawn_Human KFPH;
	local byte PerkLv;
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
	local string PerkLvText;
	local vector ScreenPos;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local color TempColor;
	
	KFPH = KFPawn_Human(KFPlayerOwner.Pawn);
	if(KFPH == None)
		return false;
	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 4.f;

	ScreenPos.X = CenterX;
	ScreenPos.Y = CenterY;
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}

	//Draw health bar
		//Draw health up limit
	Canvas.SetPos(ScreenPos.X + (BarLength * 0.5f) + BarSpace, ScreenPos.Y);
	Canvas.DrawRect(2, BarHeight);
	//if player's health is under HealthMax
	if( KFPH.Health - KFPH.HealthMax <=0)
	{
		Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);	
	}
	else
	{
		//First draw the original health bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		//Then draw overclocked health bar	
		Percentage = FMin(float(KFPH.Health - KFPH.HealthMax) / 75.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, OverclockedHealthColor);
	}

	//Draw armor bar
	//if player's armor is under MaxArmor
	if( KFPH.Armor - KFPH.MaxArmor <=0)
	{
		Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);		
	}
	else
	{
		//First draw the original armor bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		//Then draw overclocked armor bar
		Percentage = FMin(float(KFPH.Armor - KFPH.MaxArmor) / 100.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, OverclockedArmorColor);	
	}


	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight * 3.8);
	Canvas.DrawText( KFPRI.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
	Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PerkIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.6);
	PerkLv=KFPRI.GetActivePerkLevel();
	if(PerkLv <= 10)
		PerkLvText = "Rookie";
	else if(PerkLv <= 20)
		PerkLvText = "Experienced";
	else
		PerkLvText = "Mastered";
	Canvas.DrawText( PerkLvText @KFPRI.CurrentPerkClass.default.PerkName,,FontScale * FriendlyHudScale, FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none )
	{
		if( KFPRI.PerkSupplyLevel == 2 )
		{
			if( KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierActiveColor;
			}
			else if( KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierHalfUsableColor;
			}
			else
			{
				TempColor = SupplierUsableColor;
			}
		}
		else if( KFPRI.PerkSupplyLevel == 1 )
		{
			TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
		}

		Canvas.SetDrawColorStruct( TempColor );
		Canvas.SetPos( ScreenPos.X + BarLength * 0.5f + 2*BarSpace + 2, ScreenPos.Y - BarHeight * 2 );
		Canvas.DrawTile( KFPRI.CurrentPerkClass.static.GetInteractIcon(), PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256); 
	}

	return true;
}

//*********************************************************
//* Render Main
//*********************************************************

/* Use code from DrawCrosshair to draw normal HUD with Status and
 avoid being scaled usually when you see a friendly pawn in your
 viewport, still despite the original crosshair if user close it,
 make it completely a separated crosshair */
function DrawASC()
{
	local KFPawn KFP;
	local KFWeapon KFWP;
	local bool bMonsterPawn, bDrawCrosshairNoWeapon;
	local KFPerk MyKFPerk;
		
	// Only draw the crosshair if we're not in a vehicle and we have a living pawn
    if ( PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health > 0  )
	{
		bIsPlayerDead=False;
		KFWP = KFWeapon(PlayerOwner.Pawn.Weapon);
		MyKFPerk = KFPlayerController(PlayerOwner).GetPerk();

		bMonsterPawn = PlayerOwner.GetTeamNum() == 255;

		// If our pawn class uses a crosshair regardless of weapon, draw it
		KFP = KFPawn( PlayerOwner.Pawn );
		bDrawCrosshairNoWeapon = KFP.bNeedsCrosshair;

        // Don't draw the crosshair if we're not a monster with a weapon class, or we're not forcing the crosshair for the zed without a weapon
        if( bMonsterPawn )
        {
        	HECS=HE_Player_Monster;
            if( !bDrawCrosshairNoWeapon )
            {
				HECS=HE_Player_NoWeap;
                return;
            }
        }

		// Don't draw the crosshair if we don't have a weapon, or are using ironsights
		if( !bDrawCrosshairNoWeapon )
		{
	        if( (!bMonsterPawn && MyKFPerk == none) || KFWP == none || !bForceDrawCrosshair && (KFWP.bUsingSights /*|| KFWP.bResting*/) )
			{
				HECS=HE_Player_UsingIronsight;
	            return;
			}

			// Skip if weapon is missing spread settings
			if ( KFWP.Spread.Length == 0 && !bForceDrawCrosshair )
			{
				HECS=HE_WeapNotGuns;
				return;
			}
		}
		else
			HECS=HE_Player_NoWeap;

		// Don't draw the crosshair if our special move won't allow it
		if( KFP.IsDoingSpecialMove() && !KFP.SpecialMoves[KFP.SpecialMove].CanDrawCrosshair() )
		{
			HECS=HE_Player_SpecialMoveDontAllow;
			return;
		}
		DrawAsCAim(bASSAim, CSMode);
	}
	else if(PlayerOwner.Pawn.Health <= 0)
	{
		bIsPlayerDead=True;
		HECS=HE_Player_Dead;
	}
}

//Draw Energy Bar
function DrawEnergyBar(float BarPercentage, float BarLength, Color BarColor)
{
	local float fStartX, fStartY;
	local float LX, LY;
	
	fStartX=CenterX - ScreenX*0.15f; //0.3f is the length of the bar
	fStartY=ScreenY*0.85;
	
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.StrLen("Press Q to Release!", LX, LY);
	
	//background for status bar
	Canvas.SetDrawColorStruct(EnergyBarColor);
	
	Canvas.SetPos(fStartX, fStartY);
	//Left vertical
	Canvas.DrawRect(1, LY+2);
	//Up horizonal
	Canvas.DrawRect(ScreenX*0.3f, 1);
	
	Canvas.SetPos(fStartX, fStartY+LY+2);
	//Down horizonal
	Canvas.DrawRect(ScreenX*0.3f, 1);
	
	Canvas.SetPos(fStartX+ScreenX*0.3f, fStartY);
	//Right vertical
	Canvas.DrawRect(1, LY+2);

	//Forground for status bar, which means a baaaaaar that indicate the percent
	if(BarPercentage == 1.f)
		Canvas.SetDrawColor(78, 238, 148, 255);
	else
		Canvas.SetDrawColorStruct(BarColor);
	Canvas.SetPos(fStartX + 1 , fStartY + 2);  // Adjust pos for border
	Canvas.DrawTile(PlayerStatusBarBGTexture, (ScreenX*0.3f - 2.f) * BarPercentage, LY-2, 0, 0, 32, 32);
	
	//Notify player if it's full energy
	//Pos is at the right up of the bar, but at CenterX
	Canvas.SetPos(CenterX - LX*0.5, fStartY);
	
	//Draw Flash Anim
	if(EnergyTextFlagTimerFlag && BarPercentage==1.f)
	{
		SetTimer(0.5f, True, 'SetEnergyTextFlag');
		EnergyTextFlagTimerFlag=False;
	}
	if( !EnergyTextFlagTimerFlag && BarPercentage!=1.f)
	{
		SetTimer(0.f, False, 'SetEnergyTextFlag');
		EnergyTextFlag=False;
		EnergyTextFlagTimerFlag=True;
	}
	if(EnergyTextFlag)
	{
		Canvas.SetDrawColor(255, 48, 48, 192);
		Canvas.DrawText("Press Q to Release!");
	}
}

//Draw skill used notify
simulated function FuncDrawSkillMsg()
{
	local float LX, LY;
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(MainHUDColor);
	Canvas.StrLen(SkillNotification, LX, LY);
	Canvas.SetPos(CenterX - LX*0.5f, CenterY*0.45f - LY);
	Canvas.DrawText(SkillNotification);
}

/*Rewrite sth in super.super class, just copy the
  super class's code */
function DrawHUD()
{
	//local vector ViewPoint;
	//local rotator ViewRotation;
	local float XL, YL, YPos;
	local vector ViewPoint;
	local rotator ViewRotation;
	local KFPawn_Human KFPH;
	local vector ViewLocation, ViewVector, PlayerPartyInfoLocation;
    local array<PlayerReplicationInfo> VisibleHumanPlayers;
    local array<sHiddenHumanPawnInfo> HiddenHumanPlayers;
    
    ScreenX=CenterX*2;
	ScreenY=CenterY*2;
	StartX=ScreenX*PresetX;
	StartY=ScreenY*PresetY;

    // Draw weapon HUD underneath everything else
    if( KFPlayerOwner != none && KFPlayerOwner.Pawn != none && KFPlayerOwner.Pawn.Weapon != none )
    {
    	KFPlayerOwner.Pawn.Weapon.DrawHUD( self, Canvas );
    }
	
	//-------------------------------------------HUD Class
	if ( bShowOverlays && (PlayerOwner != None) )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}
	PlayerOwner.DrawHud( Self );

	//-------------------------------------------KFHUDBase class
	// Cache GRI
    if( KFGRI == none )
    {
        KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
    }

    // Don't draw canvas HUD in cinematic mode
	if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
	{
		return;
	}

	// Draw the crosshair for casual mode
	if( KFPlayerOwner != none && (bDrawCrosshair || bForceDrawCrosshair || KFPlayerOwner.GetTeamNum() == 255) )
	{
        DrawCrosshair();
    }

	//Draw Assistant Crosshair
	DrawASC();
	//----------------------------------Main HE_HUD Customized Draw Flow Put Here!-----------------------------
	DrawHE_Main(StartX, StartY, LastX, LastY);
	
	if(bDrawEnergyBar)
		DrawEnergyBar(EnergyBarPercent, 80.f, Default_OverclockedHealthColor);
	
	if(bDrawSkillMsg)
		FuncDrawSkillMsg();
	
	if(bDrawDebug)
		DrawDebug(LastX, LastY);
	if(bDrawDebugPI)
	{
		DrawDebugHumanPlayerInfo();
		DrawPlayerHealthLowIcon(KFPawn_Human(KFPlayerOwner.Pawn), True);
	}
	//---------------------------------------------------------------------------------------------------------
    // Friendly player status
    if( PlayerOwner.GetTeamNum() == 0 )
    {
		if( KFPlayerOwner != none )
		{
		    KFPlayerOwner.GetPlayerViewPoint( ViewLocation, ViewRotation );
		}
		ViewVector = vector(ViewRotation);

	    Canvas.EnableStencilTest(true);
		foreach WorldInfo.AllPawns( class'KFPawn_Human', KFPH )
		{
			if( KFPH.IsAliveAndWell() && KFPH != KFPlayerOwner.Pawn && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised )
			{
				PlayerPartyInfoLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1) );
				if(`TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f && Normal(PlayerPartyInfoLocation - ViewLocation) dot ViewVector > 0.f )
				{
					DrawPlayerHealthLowIcon(KFPH, False);
					if( DrawFriendlyHumanPlayerInfo(KFPH) )
					{
						VisibleHumanPlayers.AddItem( KFPH.PlayerReplicationInfo );
					}
					else
					{
						HiddenHumanPlayers.Insert( 0, 1 );
                    	HiddenHumanPlayers[0].HumanPawn = KFPH;
                    	HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
					}
				}
				else 
                {
                    HiddenHumanPlayers.Insert( 0, 1 );
                    HiddenHumanPlayers[0].HumanPawn = KFPH;
                    HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
                }
			}
		}

		if( !KFGRI.bHidePawnIcons )
		{
			// Draw hidden players
			CheckAndDrawHiddenPlayerIcons( VisibleHumanPlayers, HiddenHumanPlayers );

			// Draw last remaining zeds
			CheckAndDrawRemainingZedIcons();

			//Draw our current objective's location
			if(KFGRI.CurrentObjective != none)
			{
				DrawObjectiveHUD();
			}
		}

		Canvas.EnableStencilTest(false);
	}
	//---------------------------------------------------------KFGFxHudWrapper Class
	// Don't draw canvas HUD in cinematic mode
    if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
    {
        return;
    }

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

//Draw need healing icon when player's health is low
simulated function bool DrawPlayerHealthLowIcon(KFPawn_Human KFPH, optional bool isDebug)
{
	local float LX, LY;
	local string NotifyText;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	
	NotifyText="Pending...";

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}
	
	if(isDebug)
	{
		ScreenPos.X = CenterX;
		ScreenPos.Y = CenterY;
	}
	else
	{
		TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1.1f) );
		ScreenPos = Canvas.Project( TargetLocation );
	}
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}
	
	//Init draw pattern
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	//Only draw when teammates' health is below critical notify threshold
	if( KFPH.Health <= CriticalHealthRateNotify)
	{
		Canvas.SetDrawColorStruct(CriticalSeverityColor);
		Canvas.StrLen("Dying", LX, LY);
		NotifyText="Dying";
		//Draw need healing icon and text
		Canvas.SetPos(ScreenPos.X - 16.f, ScreenPos.Y - 16.f);
		Canvas.DrawTile(class'KFPerk_FieldMedic'.default.PerkIcon, 32.f * FriendlyHudScale, 32.f * FriendlyHudScale, 0, 0, 256, 256 );
		Canvas.SetPos(ScreenPos.X - LX*0.5f, ScreenPos.Y + 2.f + 16.f);
		Canvas.DrawText(NotifyText);
		return true;
	}
	return False;
}

//Re-work sth at DrawKFBar, draw a transparent but sketched tile
simulated function DrawKFBar( float BarPercentage, float BarLength, float BarHeight, float XPos, float YPos, Color BarColor )
{
	//background for status bar
	Canvas.SetDrawColorStruct(PlayerBarBGColor);
	
	Canvas.SetPos(XPos, YPos);
	//Left vertical
	Canvas.DrawRect(1, BarHeight);
	//Up horizonal
	Canvas.DrawRect(BarLength, 1);
	
	Canvas.SetPos(XPos, YPos+BarHeight);
	//Down horizonal
	Canvas.DrawRect(1, BarHeight);
	
	Canvas.SetPos(XPos+BarLength, YPos);
	//Right vertical
	Canvas.DrawRect(1, BarHeight);

	//Forground for status bar, which means a baaaaaar that indicate the health percent
	Canvas.SetDrawColorStruct(BarColor);
	Canvas.SetPos(XPos, YPos + 1);  // Adjust pos for border
	Canvas.DrawTile(PlayerStatusBarBGTexture, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0, 0, 0, 32, 32);
}

//Re-work sth at DrawFriendlyHumanPlayerInfo
simulated function bool DrawFriendlyHumanPlayerInfo(KFPawn_Human KFPH)
{
	local byte PerkLv;
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
	local string PerkLvText;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local color TempColor;

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 2.f;

	TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.2f) );

	ScreenPos = Canvas.Project( TargetLocation );
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}

	//Draw health bar
		//Draw health up limit
	Canvas.SetPos(ScreenPos.X + (BarLength * 0.5f) + BarSpace, ScreenPos.Y);
	Canvas.DrawRect(2, BarHeight);
	//if player's health is under HealthMax
	if( KFPH.Health - KFPH.HealthMax <=0)
	{
		Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);	
	}
	else
	{
		//First draw the original health bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		//Then draw overclocked health bar	
		Percentage = FMin(float(KFPH.Health - KFPH.HealthMax) / 75.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, OverclockedHealthColor);
	}

	//Draw armor bar
	//if player's armor is under MaxArmor
	if( KFPH.Armor - KFPH.MaxArmor <=0)
	{
		Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);		
	}
	else
	{
		//First draw the original armor bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		//Then draw overclocked armor bar
		Percentage = FMin(float(KFPH.Armor - KFPH.MaxArmor) / 100.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, OverclockedArmorColor);	
	}


	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight * 3.8);
	Canvas.DrawText( KFPRI.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
	Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PerkIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.6);
	PerkLv=KFPRI.GetActivePerkLevel();
	if(PerkLv <= 10)
		PerkLvText = "Rookie";
	else if(PerkLv <= 20)
		PerkLvText = "Experienced";
	else
		PerkLvText = "Mastered";
	Canvas.DrawText( PerkLvText @KFPRI.CurrentPerkClass.default.PerkName,,FontScale * FriendlyHudScale, FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none )
	{
		if( KFPRI.PerkSupplyLevel == 2 )
		{
			if( KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierActiveColor;
			}
			else if( KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierHalfUsableColor;
			}
			else
			{
				TempColor = SupplierUsableColor;
			}
		}
		else if( KFPRI.PerkSupplyLevel == 1 )
		{
			TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
		}

		Canvas.SetDrawColorStruct( TempColor );
		Canvas.SetPos( ScreenPos.X + BarLength * 0.5f + 2*BarSpace + 2, ScreenPos.Y - BarHeight * 2 );
		Canvas.DrawTile( KFPRI.CurrentPerkClass.static.GetInteractIcon(), PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256); 
	}

	return true;
}

//A function that draw an assistant crosshair despite of the original
function DrawAsCAim(bool Enable, optional AsCMode mode=AsC_Default)
{
	if(!Enable)
	{
		HECS=HE_Player_Closed;
		return;
	}
	HECS=HE_Good;
	Canvas.SetDrawColorStruct(CrosshairColor);
	
	//Crosshair
	if( mode==AsC_Default || mode==AsC_CenterDot)
	{
		//Up
		Canvas.SetPos(CenterX-ASSAim_Width*0.5f, CenterY-ASSAim_Space-ASSAim_Length);
		Canvas.DrawRect(ASSAim_Width,ASSAim_Length);
		//Left
		Canvas.SetPos(CenterX-ASSAim_Space-ASSAim_Length, CenterY-ASSAim_Width*0.5f);
		Canvas.DrawRect(ASSAim_Length,ASSAim_Width);	
		//Down
		Canvas.SetPos(CenterX-ASSAim_Width*0.5f, CenterY+ASSAim_Space);
		Canvas.DrawRect(ASSAim_Width,ASSAim_Length);
		//Right
		Canvas.SetPos(CenterX+ASSAim_Space, CenterY-ASSAim_Width*0.5f);
		Canvas.DrawRect(ASSAim_Length,ASSAim_Width);
	}
	if( mode==AsC_CenterDot || mode==AsC_OnlyDot)
	{
		Canvas.SetPos(CenterX-1, CenterY-1);
		Canvas.DrawRect(2, 2);
	}	
}

//Draw debug info
function DrawDebug(float X, float Y, optional out float LastLX, optional out float LastLY)
{
	local float LX, LY;
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(DebugHUDColor);
	
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

//Draw right side hud info Main
function DrawHE_Main(float X, float Y, optional out float LastLX, optional out float LastLY)
{
	local float LX, LY;
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(MainHUDColor);
	
	Canvas.SetPos(X, Y);
	//Canvas.DrawText("---Healing Extend HUD Info---",, HUDMainTextScale, HUDMainTextScale);
	Canvas.StrLen("---Healing Extend HUD Info---", LX, LY);
	LastLY=Y+LY;
	LastLX=X;

	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText(" _>"$Int(ScreenX)$" x "$Int(ScreenY),, HUDMainTextScale, HUDMainTextScale);
	LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText(" _>"$WorldInfo.NetMode,, HUDMainTextScale, HUDMainTextScale);
	LastLY=LastLY+LY;

	
	//Canvas.SetPos(LastLX, LastLY);
////	Canvas.DrawText("---Healing Extend HUD Info---");
	//Canvas.DrawText(" _>"$KFPlayerOwner.PlayerReplicationInfo.PlayerName,, HUDMainTextScale, HUDMainTextScale);
	//LastLY=LastLY+LY;
	
	//Canvas.SetPos(LastLX, LastLY);
////	Canvas.DrawText("---Healing Extend HUD Info---");
	//Canvas.DrawText(" _>Is now alive:"$!bIsPlayerDead,, HUDMainTextScale, HUDMainTextScale);
	//LastLY=LastLY+LY;
	
	Canvas.SetPos(LastLX, LastLY);
//	Canvas.DrawText("---Healing Extend HUD Info---");
	Canvas.DrawText(" _>"$HECS,, HUDMainTextScale, HUDMainTextScale);
	LastLY=LastLY+LY;
}

//Default Properties
defaultproperties
{
	bDrawDebug=False
	bDrawDebugPI=False
	bASSAim=True
	CSMode=AsC_Default;
	bIsPlayerDead=False
	HECS=HE_NoneInit
	
	bDrawEnergyBar=False;
	
	bDrawSkillMsg=False;
	bPlayerPressedQ=False;
	
	EnergyTextFlag=False;
	EnergyTextFlagTimerFlag=True;
	
	Default_HurtHealthRateNotify=85;
	Default_CriticalHealthRateNotify=50; //Need asking people
	
	Default_MainHUDColor=(R=255, G=255, B=0, A=192) //Yellow
	Default_DebugHUDColor=(R=255, G=192, B=203, A=192) //Pink
	Default_CrosshairColor=(R=255, G=48, B=48, A=192) //Red
	Default_OverclockedArmorColor=(R=78, G=238, B=148, A=192) //Sea Green 2
	Default_OverclockedHealthColor=(R=95, G=210, B=255, A=192) //Original blue
	Default_LowSeverityColor=(R=255, G=255, B=0, A=192); //Yellow
	Default_CriticalSeverityColor=(R=255, G=48, B=48, A=192); //Red
	Default_EnergyBarColor=(R=248, G=248, B=255, A=192)//Ghost White
	
	PresetX=0.039f
	PresetY=0.28f
	
	//RemoteRole=Role_SimulatedProxy
	
	ArmorColor=(R=238, G=233, B=233, A=192)//Snow
	HealthColor=(R=255, G=20, B=147, A=192)//Deep Pink
	PlayerBarBGColor=(R=160, G=32, B=240, A=0) //Set to purple, but completely transparant now
	PlayerBarTextColor=(R=248, G=248, B=255, A=192)//Navy Blue
	PlayerBarIconColor=(R=248, G=248, B=255, A=192)//Ghost White

	SupplierActiveColor=(R=128, G=128, B=128, A=192)
	SupplierUsableColor=(R=255, G=0, B=0, A=192)
	SupplierHalfUsableColor=(R=220, G=200, B=0, A=192)

    ZedIconColor=(R=0, G=191, B=255, A=192)//Deep Sky Blue
}