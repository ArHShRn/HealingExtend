class HeadshotRecover extends Mutator;

var KFPawn_Human ThisP;
var int HitZoneIndex;
var KFPawn ImpactTarget;
var KFPawn_Monster KFPM_Victim;
var KFPlayerController doer;
var Weapon PWeapon;
var bool bIsClearMessage;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(5, true, 'LogStatus');
}

function ModifyPlayer(Pawn Other)
{
	super.ModifyPlayer(Other);
	ThisP=KFPawn_Human(Other);
	doer=KFPlayerController(ThisP.Controller);	
}

Event Tick( float DeltaTime )
{
	local Actor Hit;
	
	Hit=GetWeapHit(ThisP).HitActor;
	
	ImpactTarget=KFPawn(Hit);
	KFPM_Victim=KFPawn_Monster(ImpactTarget);
	
	if(Hit!=None && !`IsInZedTime(self))
	{
		//`Log("[ArHShRn.Mutators] ImpactTarget="$ImpactTarget.Name$" KFPM_Victim="$KFPM_Victim.Name);
		if(KFPM_Victim!=None && !KFPM_Victim.bIsHeadless && KFPM_Victim.IsAliveAndWell())
		{
			HitZoneIndex=KFPM_Victim.HitZones.Find('ZoneName', GetWeapHit(ThisP).HitInfo.BoneName);
			//doer.ServerTeamSay("[Headshot]Instant Heal 1 HP");
			doer.Pawn.Health=Min(doer.Pawn.Health+1,doer.Pawn.HealthMax);
		}
		bIsClearMessage=True;
	}
	if(`IsInZedTime(self))
	{
		if(bIsClearMessage)
			doer.ServerTeamSay("[Zedtime]Enable:HeadShot Assistant");
		HeadshotAssis(ThisP);
		bIsClearMessage=False;
	}

}

simulated function LogStatus()
{
	`Log("[ArHShRn.Mutators] HeadshotRecover Mut is working fine!");
}


simulated function ImpactInfo GetWeapHit(KFPawn_Human P)
{
	local Weapon			PlayerWeap;
	local vector			StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo		RealImpact;

	PlayerWeap = P.Weapon;
	
	// define range to use for CalcWeaponFire()
	StartTrace = P.GetWeaponStartTraceLocation();
	EndTrace = StartTrace + vector(PlayerWeap.GetAdjustedAim(StartTrace)) * PlayerWeap.GetTraceRange();

	// Perform shot
	if(PlayerWeap.IsFiring())
		RealImpact = PlayerWeap.CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	else
		RealImpact.HitActor=None;
	
	//FlushPersistentDebugLines();
	//DrawDebugSphere( StartTrace, 10, 10, 0, 255, 0 );
	//DrawDebugSphere( EndTrace, 10, 10, 255, 0, 0 );
	//DrawDebugSphere( RealImpact.HitLocation, 10, 10, 0, 0, 255 );
	
	return RealImpact;
}

simulated function HeadshotAssis(KFPawn_Human P)
{
	local Weapon			PlayerWeap;
	local vector			StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo		RealImpact;

	PlayerWeap = P.Weapon;
	
	StartTrace = P.GetWeaponStartTraceLocation();
	EndTrace = StartTrace + vector(PlayerWeap.GetAdjustedAim(StartTrace)) * PlayerWeap.GetTraceRange();

	RealImpact = PlayerWeap.CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	
	FlushPersistentDebugLines();
	DrawDebugSphere( RealImpact.HitLocation, 10, 10, 0, 0, 255 );
}

defaultproperties
{
	bIsClearMessage=False;
}