class Weap_HMT401 extends KFWeap_MedicBase;

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Assault;
}


defaultproperties
{
	// Healing charge
    HealAmount=20 //Changed from 18 to 20
	HealFullRechargeSeconds=4 //from 10 to 4

	// Inventory
	InventorySize=1 //from 7 to 1
	GroupPriority=100
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MedicAssault'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
    MeshFOV=75
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WEP_1P_Medic_Assault_MESH.Wep_1stP_Medic_Assault_Rig'
		AnimSets(0)=AnimSet'WEP_1P_Medic_Assault_ANIM.Wep_1stP_Medic_Assault_Anim'
	End Object

	Begin Object Name=StaticPickupComponent
		StaticMesh=StaticMesh'WEP_3P_Pickups_MESH.Wep_Medic_Assault_Pickup'
	End Object

	AttachmentArchetype=KFWeaponAttachment'WEP_Medic_Assault_ARCH.Wep_Medic_Assault_3P'

   	// Zooming/Position
	PlayerViewOffset=(X=15.0,Y=6.5,Z=-3)
	IronSightPosition=(X=12,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=75 //increase from 30 to 35
	SpareAmmoCapacity[0]=750 //decrease to 10 mags
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=10 //200 to 150
	minRecoilPitch=-10//150 to 100
	maxRecoilYaw=10
	minRecoilYaw=-10
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Assault_Medic'
	FireInterval(DEFAULT_FIREMODE)=+0.05 // 650 to 1200
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=30.0 //decrease 25%
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALTFIRE_FIREMODE
	AmmoCost(ALTFIRE_FIREMODE)=10 //decrease 5%+

	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=27
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Assault_Medic'

	// Fire Effects
	MuzzleFlashTemplate=KFMuzzleFlash'WEP_Medic_Assault_ARCH.Wep_Medic_Assault_MuzzleFlash'
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_Single')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Fire_1P_EndLoop')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicAssault.Play_SA_MedicAssault_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

   	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic' //Only Medic
   	//AssociatedPerkClasses(1)=class'KFPerk_Commando'
}