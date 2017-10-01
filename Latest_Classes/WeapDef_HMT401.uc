 class WeapDef_HMT401 extends KFWeaponDefinition
abstract;

static function string GetItemName()
{return "HMTech-401 Superb";}

static function string GetItemDescription()
{return "A Test HMTech-401 Version By ArHShRn";}

static function string GetItemLocalization(string KeyName)
{
	return "HMT401 BiohaZard";
}

defaultproperties
{
	WeaponClassPath="HealingExtend.Weap_HMT401"

	BuyPrice=10 //test
	AmmoPricePerMag=10 //test
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicAssault"

	EffectiveRange=70
}
