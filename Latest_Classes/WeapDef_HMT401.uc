class WeapDef_HMT401 extends KFWeaponDefinition
	abstract;

static function string GetItemName()
{return "HMTech-401 BiohaZard";}

static function string GetItemDescription()
{return "Biohazard Edition";}

static function string GetItemLocalization(string KeyName)
{
	return "HMTech-401 BiohaZard";
}

defaultproperties
{
	WeaponClassPath="HealingExtend.Weap_HMT401"

	BuyPrice=1500
	AmmoPricePerMag=40
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicAssault"

	EffectiveRange=70
}
