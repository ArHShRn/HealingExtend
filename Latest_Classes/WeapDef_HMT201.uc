class WeapDef_HMT201 extends KFWeaponDefinition
	abstract;

static function string GetItemName()
{return "HMTech-201 Storm";}

static function string GetItemDescription()
{return "Storm Edition";}

static function string GetItemLocalization(string KeyName)
{
	return "HMTech-201 Storm";
}

DefaultProperties
{
	WeaponClassPath="HealingExtend.Weap_HMT201"

	BuyPrice=650
	AmmoPricePerMag=20
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicSMG"

	EffectiveRange=70
}