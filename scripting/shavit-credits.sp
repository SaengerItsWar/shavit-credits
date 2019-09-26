#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>
#include <autoexecconfig>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3.5"
chatstrings_t gS_ChatStrings;
stylesettings_t gA_StyleSettings[STYLE_LIMIT];

public Plugin myinfo = 
{
	name = "[shavit] Credits | Knxrl Store", 
	author = "Farhannz, Modified by SaengerItsWar and totenfluch", 
	description = "Gives Kxnrl Store Credits for records", 
	version = PLUGIN_VERSION, 
	url = "https://deadnationgaming.eu/"
}

// convars
ConVar g_cvNormalEnabled;
ConVar g_cvWREnabled;
ConVar g_cvEnabledPb;
ConVar g_cvT1Enabled;
ConVar g_cvNormalAmount;
ConVar g_cvWrAmount;
ConVar g_cvPBAmount;
ConVar g_cvBNormalEnabled;
ConVar g_cvBWREnabled;
ConVar g_cvEnabledBPb;
ConVar g_cvNormalBAmount;
ConVar g_cvWrBAmount;
ConVar g_cvBPbAmount;

//globals
char g_cMap[160];
int g_iTier;
int g_iStyle;
float g_fPB;

public void OnAllPluginsLoaded()
{
	if(!LibraryExists("store"))
	{
		SetFailState("Kxnrl store is required for the plugin to work.");
	}
}

public void OnPluginStart()
{
	LoadTranslations("shavit-credits.phrases");
	AutoExecConfig_SetFile("shavit-credits");
	AutoExecConfig_SetCreateFile(true);
	CreateConVar("shavit_credtis_version", PLUGIN_VERSION, "Kxnrl-Store : Shavit Credits for records", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_cvNormalEnabled = AutoExecConfig_CreateConVar("credits_enable_normal", "1", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvWREnabled = AutoExecConfig_CreateConVar("credits_enable_wr", "1", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledPb = AutoExecConfig_CreateConVar("credits_enable_pb", "1", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvT1Enabled = AutoExecConfig_CreateConVar("credits_enable_t1", "0", "Enable/Disable given credits for Tier 1. This has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_cvNormalAmount = AutoExecConfig_CreateConVar("credits_amount_normal", "10.0", "How many points should be given for finishing a Map?(will be claculated per Tier(amount_normal*Tier))", 0, true, 1.0, false);
	g_cvWrAmount = AutoExecConfig_CreateConVar("credits_amount_wr", "25.0", "How many points should be given for breaking a Map record?(will be calculated per Tier(amount_wr*Tier))", 0, true, 1.0, false);
	g_cvPBAmount = AutoExecConfig_CreateConVar("credits_amount_pb", "10.0", "How many point should be given for breaking the own Personal Best?(will be calculated per Tier(amount_pb*Tier))", 0, true, 1.0, false);
	g_cvBNormalEnabled = AutoExecConfig_CreateConVar("credits_enable_normal_bonus", "0", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvBWREnabled = AutoExecConfig_CreateConVar("credits_enable_wr_bonus", "0", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledBPb = AutoExecConfig_CreateConVar("credits_enable_pb_bonus", "0", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvNormalBAmount = AutoExecConfig_CreateConVar("credits_amount_normal_bonus", "10.0", "How many points should be given for finishing a Map?", 0, true, 1.0, false);
	g_cvWrBAmount = AutoExecConfig_CreateConVar("credits_amount_wr_bonus", "25.0", "How many points should be given for breaking a Map record?", 0, true, 1.0, false);
	g_cvBPbAmount = AutoExecConfig_CreateConVar("credits_amount_pb_bonus", "10.0", "How many point should be given for breaking the own Personal Best?", 0, true, 1.0, false);
	
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}


public void OnMapStart()
{
	GetCurrentMap(g_cMap, sizeof(g_cMap));
	GetMapDisplayName(g_cMap, g_cMap, sizeof(g_cMap));
	g_iTier = Shavit_GetMapTier(g_cMap);
}

public void Shavit_OnChatConfigLoaded()
{
	Shavit_GetChatStrings(sMessagePrefix, gS_ChatStrings.sPrefix, sizeof(chatstrings_t::sPrefix));
	Shavit_GetChatStrings(sMessageText, gS_ChatStrings.sText, sizeof(chatstrings_t::sText));
	Shavit_GetChatStrings(sMessageWarning, gS_ChatStrings.sWarning, sizeof(chatstrings_t::sWarning));
	Shavit_GetChatStrings(sMessageVariable, gS_ChatStrings.sVariable, sizeof(chatstrings_t::sVariable));
	Shavit_GetChatStrings(sMessageVariable2, gS_ChatStrings.sVariable2, sizeof(chatstrings_t::sVariable2));
	Shavit_GetChatStrings(sMessageStyle, gS_ChatStrings.sStyle, sizeof(chatstrings_t::sStyle));
}

public void Shavit_OnStyleConfigLoaded(int styles)
{
	if (styles == -1)
	{
		styles = Shavit_GetStyleCount();
	}
	
	for (int i; i < styles; i++)
	{
		Shavit_GetStyleSettings(i, gA_StyleSettings[i]);
		
	}
}

public void Shavit_OnLeaveZone(int client, int zone, int track, int id, int entity)
{
	g_iStyle = Shavit_GetBhopStyle(client);
	g_fPB = Shavit_GetClientPB(client, g_iStyle, track);
}
public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track)
{
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));

	if (StrContains(sStyleSpecialString, "segments") != -1)
    		return;
	
	if (g_cvNormalEnabled.BoolValue == true)
	{
		if (g_cvT1Enabled.BoolValue == true || g_iTier != 1)
		{
			
			if(track == 0)
			{
				
				float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
				float fResult = (g_cvNormalAmount.IntValue * g_iTier) * fMultiplier;
				int iRoundResult = RoundFloat(fResult);
				int iCredits = iRoundResult;

				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "finishing map");

				Shavit_PrintToChat(client, "%t", "NormalFinish", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				
			}
			
			else if(g_cvBNormalEnabled.BoolValue == true)
			{
				float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
				float fResult = g_cvNormalBAmount.IntValue * fMultiplier;
				int iRoundResult = RoundFloat(fResult);
				int iCredits = iRoundResult;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "finishing map Bonus");
				Shavit_PrintToChat(client, "%t", "NormalBonusFinish", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
	}
	
	if (g_cvEnabledPb.BoolValue == true)
	{
		if (time <= g_fPB)
		{
			if(track == 0)
			{
				float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
				float fResult = (g_cvPBAmount.IntValue * g_iTier) * fMultiplier;
				int iRoundResult = RoundFloat(fResult);
				int iCredits = iRoundResult;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "Personal Best");
				Shavit_PrintToChat(client, "%t", "PersonalBest", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			
			else if(g_cvEnabledBPb.BoolValue == true)
			{
				float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
				float fResult = g_cvBPbAmount.IntValue * fMultiplier;
				int iRoundResult = RoundFloat(fResult);
				int iCredits = iRoundResult;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "Bonus Personal Best");
				Shavit_PrintToChat(client, "%t", "BonusPersonalBest", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
	}
}

public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track)
{
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));

	if (StrContains(sStyleSpecialString, "segments") != -1)
    		return;
		
	if (g_cvWREnabled.BoolValue == true)
	{
		if(track == 0)
		{
			
			float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
			float fResult = (g_cvWrAmount.IntValue * g_iTier) * fMultiplier;
			int iRoundResult = RoundFloat(fResult);
			int iCredits = iRoundResult;
		
			Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "breaking map record");
			Shavit_PrintToChat(client, "%t", "WorldRecord", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
		}
		
		else if(g_cvBWREnabled.BoolValue == true) {
			float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
			float fResult = g_cvWrBAmount.IntValue * fMultiplier;
			int iRoundResult = RoundFloat(fResult);
			int iCredits = iRoundResult;
		
			Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits, "breaking Bonus record");

			Shavit_PrintToChat(client, "%t", "BonusWorldRecord", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
		}
	}
}