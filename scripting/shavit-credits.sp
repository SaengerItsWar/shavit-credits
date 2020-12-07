#include <sourcemod>
#include <sdktools>
#include <store/store-core>
#include <shavit>
#include <convar_class>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.4.3"
chatstrings_t gS_ChatStrings;
stylesettings_t gA_StyleSettings[STYLE_LIMIT];

public Plugin myinfo = 
{
	name = "[shavit] Credits | Sourcemod Store", 
	author = "SaengerItsWar", 
	description = "Gives Sourcemod Store Credits for records", 
	version = PLUGIN_VERSION, 
	url = "https://github.com/Saenger.ItsWar"
}

// convars
Convar g_cvNormalEnabled;
Convar g_cvWREnabled;
Convar g_cvEnabledPb;
Convar g_cvT1Enabled;
Convar g_cvNormalAmount;
Convar g_cvNormalAmountAgain;
Convar g_cvWrAmount;
Convar g_cvWrAmountAgain;
Convar g_cvPBAmount;
Convar g_cvPBAmountAgain;
Convar g_cvBNormalEnabled;
Convar g_cvBWREnabled;
Convar g_cvEnabledBPb;
Convar g_cvNormalBAmount;
Convar g_cvNormalBAmountAgain;
Convar g_cvWrBAmount;
Convar g_cvWrBAmountAgain;
Convar g_cvBPbAmount;
Convar g_cvBPbAmountAgain;
Convar g_cvTasEnabled;
Convar g_cvNewCalc;

//globals
char g_cMap[160];
int g_iTier;
int g_iStyle[MAXPLAYERS+1];
float g_fPB[MAXPLAYERS+1];
int g_iCompletions[MAXPLAYERS+1];

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("store-core"))
	{
		SetFailState("Sourcemod store is required for the plugin to work.");
	}
	else if (!LibraryExists("shavit-wr"))
	{
		SetFailState("Shavit WR is required for the plugin to work.");
	}
	else if (!LibraryExists("shavit-rankings"))
	{
		SetFailState("Shavit Rankings is required for the plugin to work.");
	}
}

public void OnPluginStart()
{
	LoadTranslations("shavit-credits.phrases");
	CreateConVar("shavit_credtis_version", PLUGIN_VERSION, "Soucemod Store : Shavit Credits for records", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_cvNormalEnabled = new Convar("credits_enable_normal", "1", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvWREnabled = new Convar("credits_enable_wr", "1", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledPb = new Convar("credits_enable_pb", "1", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvT1Enabled = new Convar("credits_enable_t1", "0", "Enable/Disable given credits for Tier 1. This has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_cvNormalAmount = new Convar("credits_amount_normal", "10.0", "How many points should be given for finishing a Map?(will be claculated per Tier(amount_normal*Tier))", 0, true, 1.0, false);
	g_cvNormalAmountAgain = new Convar("credits_amount_normal_again", "5.0", "How many points should be given for finishing a Map Again?(will be claculated per Tier(amount_normal*Tier))", 0, true, 1.0, false);
	g_cvWrAmount = new Convar("credits_amount_wr", "25.0", "How many points should be given for breaking a Map record?(will be calculated per Tier(amount_wr*Tier))", 0, true, 1.0, false);
	g_cvWrAmountAgain = new Convar("credits_amount_wr_again", "12.0", "How many points should be given for breaking a Map record Again?(will be calculated per Tier(amount_wr*Tier))", 0, true, 1.0, false);
	g_cvPBAmount = new Convar("credits_amount_pb", "10.0", "How many point should be given for breaking the own Personal Best?(will be calculated per Tier(amount_pb*Tier))", 0, true, 1.0, false);
	g_cvPBAmountAgain = new Convar("credits_amount_pb_again", "5.0", "How many point should be given for breaking the own Personal Best Again?(will be calculated per Tier(amount_pb*Tier))", 0, true, 1.0, false);
	g_cvBNormalEnabled = new Convar("credits_enable_normal_bonus", "0", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvBWREnabled = new Convar("credits_enable_wr_bonus", "0", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledBPb = new Convar("credits_enable_pb_bonus", "0", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvNormalBAmount = new Convar("credits_amount_normal_bonus", "10.0", "How many points should be given for finishing a Map?", 0, true, 1.0, false);
	g_cvNormalBAmountAgain = new Convar("credits_amount_normal_bonus_again", "5.0", "How many points should be given for finishing a Map Again?", 0, true, 1.0, false);
	g_cvWrBAmount = new Convar("credits_amount_wr_bonus", "25.0", "How many points should be given for breaking a Map record?", 0, true, 1.0, false);
	g_cvWrBAmountAgain = new Convar("credits_amount_wr_bonus_again", "12.0", "How many points should be given for breaking a Map record Again?", 0, true, 1.0, false);
	g_cvBPbAmount = new Convar("credits_amount_pb_bonus", "10.0", "How many point should be given for breaking the own Personal Best?", 0, true, 1.0, false);
	g_cvBPbAmountAgain = new Convar("credits_amount_pb_bonus_again", "5.0", "How many point should be given for breaking the own Personal Best Again?", 0, true, 1.0, false);
	g_cvTasEnabled = new Convar("credits_tas_enabled", "0", "Enable Store Credits for a TAS Style?", 0, true, 0.0, true, 1.0);
	g_cvNewCalc = new Convar("credits_new_calculation", "1", "Enable the New Calculation for the credits?", 0, true, 0.0, true, 1.0);
	
	
	Convar.CreateConfig("shavit-credits");
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
	if (IsClientInGame(client) && IsFakeClient(client))
		return;
		
	if (zone == Zone_Start) {
		g_iStyle[client] = Shavit_GetBhopStyle(client);
		g_fPB[client] = Shavit_GetClientPB(client, g_iStyle[client], track);
		g_iCompletions[client] = Shavit_GetClientCompletions(client, g_iStyle[client], track);
	}
}
public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track)
{
	int accountId = Store_GetClientAccountID(client);
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));
	
	if (StrContains(sStyleSpecialString, "segments") != -1)
		return;
		
	if (!g_cvTasEnabled.BoolValue)
		if (StrContains(sStyleSpecialString, "tas") != -1)
			return;
	
	if (g_cvNormalEnabled.BoolValue == true)
	{
		if (g_cvT1Enabled.BoolValue == true || g_iTier != 1)
		{
			
			if (track == Track_Main)
			{
				if (g_iCompletions[client] == 0)
				{
					int iCredits;
				
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = (g_cvNormalAmount.IntValue * g_iTier) * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvNormalAmount.IntValue * g_iTier;
					}
				
					Store_GiveCredits(accountId, iCredits);
					
					Shavit_PrintToChat(client, "%t", "NormalFinish", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
				else if (g_iCompletions[client] >=1)
				{
					int iCredits;
				
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = (g_cvNormalAmountAgain.IntValue * g_iTier) * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvNormalAmountAgain.IntValue * g_iTier;
					}
				
					Store_GiveCredits(accountId, iCredits);
					
					Shavit_PrintToChat(client, "%t", "NormalFinishAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
			}
		}
	}
			
	if (g_cvBNormalEnabled.BoolValue == true)
	{
		if (track == Track_Bonus)
		{
			if (g_iCompletions[client] == 0)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = g_cvNormalBAmount.IntValue * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvNormalBAmount.IntValue;
				}
				
				Store_GiveCredits(accountId, iCredits);
				Shavit_PrintToChat(client, "%t", "NormalBonusFinish", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			else if (g_iCompletions[client] >=1)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = g_cvNormalBAmountAgain.IntValue * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvNormalBAmountAgain.IntValue;
				}
				
				Store_GiveCredits(accountId, iCredits);
				Shavit_PrintToChat(client, "%t", "NormalBonusFinishAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
	}
	
	
	if (g_cvEnabledPb.BoolValue == true)
	{
		if (time < g_fPB[client])
		{
			if (track == Track_Main)
			{
				if (g_iCompletions[client] == 0)
				{
					int iCredits;
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = (g_cvPBAmount.IntValue * g_iTier) * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvPBAmount.IntValue * g_iTier;
					}
					
					Store_GiveCredits(accountId, iCredits);
					Shavit_PrintToChat(client, "%t", "PersonalBest", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
				else if (g_iCompletions[client] >=1)
				{
					int iCredits;
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = (g_cvPBAmountAgain.IntValue * g_iTier) * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvPBAmountAgain.IntValue * g_iTier;
					}
					
					Store_GiveCredits(accountId, iCredits);
					Shavit_PrintToChat(client, "%t", "PersonalBestAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
			}
		}
	}
			
	if (g_cvEnabledBPb.BoolValue == true)
	{
		if (time < g_fPB[client])
		{
			if (track == Track_Bonus)
			{
				if (g_iCompletions[client] == 0)
				{
					int iCredits;
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = g_cvBPbAmount.IntValue * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvBPbAmount.IntValue;
					}
					
					Store_GiveCredits(accountId, iCredits);
					Shavit_PrintToChat(client, "%t", "BonusPersonalBest", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
				else if (g_iCompletions[client] >=1)
				{
					int iCredits;
					if (g_cvNewCalc.BoolValue == true)
					{
						float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
						float fResult = g_cvBPbAmountAgain.IntValue * fMultiplier;
						int iRoundResult = RoundFloat(fResult);
						iCredits = iRoundResult;
					}
					else
					{
						iCredits = g_cvBPbAmountAgain.IntValue;
					}
					
					Store_GiveCredits(accountId, iCredits);
					Shavit_PrintToChat(client, "%t", "BonusPersonalBestAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
				}
			}
		}
	}
	
}

public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track)
{
	int accountId = Store_GetClientAccountID(client);
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));
	
	if (StrContains(sStyleSpecialString, "segments") != -1)
		return;
		
	if (!g_cvTasEnabled.BoolValue)
		if (StrContains(sStyleSpecialString, "tas") != -1)
			return;
	
	if (g_cvWREnabled.BoolValue == true)
	{
		if (track == Track_Main)
		{
			if (g_iCompletions[client] == 0)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = (g_cvWrAmount.IntValue * g_iTier) * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvWrAmount.IntValue * g_iTier;
				}
				
				Store_GiveCredits(accountId, iCredits);
				Shavit_PrintToChat(client, "%t", "WorldRecord", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			else if (g_iCompletions[client] >=1)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = (g_cvWrAmountAgain.IntValue * g_iTier) * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvWrAmountAgain.IntValue * g_iTier;
				}
				
				Store_GiveCredits(accountId, iCredits);
				Shavit_PrintToChat(client, "%t", "WorldRecordAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
	}
		
	if (g_cvBWREnabled.BoolValue == true)
	{
		if (track == Track_Bonus)
		{
			if (g_iCompletions[client] == 0)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = g_cvWrBAmount.IntValue * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvWrBAmount.IntValue;
				}
				
				Store_GiveCredits(accountId, iCredits);
				
				Shavit_PrintToChat(client, "%t", "BonusWorldRecord", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			else if (g_iCompletions[client] >=1)
			{
				int iCredits;
				if (g_cvNewCalc.BoolValue == true)
				{
					float fMultiplier = gA_StyleSettings[style].fRankingMultiplier;
					float fResult = g_cvWrBAmountAgain.IntValue * fMultiplier;
					int iRoundResult = RoundFloat(fResult);
					iCredits = iRoundResult;
				}
				else
				{
					iCredits = g_cvWrBAmountAgain.IntValue;
				}
				
				Store_GiveCredits(accountId, iCredits);
				
				Shavit_PrintToChat(client, "%t", "BonusWorldRecordAgain", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
	}
}
