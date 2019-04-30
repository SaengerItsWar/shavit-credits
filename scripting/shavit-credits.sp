#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>

#define PLUGIN_VERSION "1.2.2"
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store",
	author = "Farhannz, Modified by Saengerkrieg12",
	description = "Gives Zephyrus Store Credits on map finish and breaking records",
	version = PLUGIN_VERSION,
	url = "https://deadnationgaming.eu/"
};

ConVar g_hNormalEnabled;
int g_iNormalEnabled
ConVar g_hWREnabled;
int g_iWREnabled;
ConVar g_hEnabledPb;
int g_iPBEnabled;
ConVar g_hT1Enabled;
int g_iT1Enabled;
ConVar g_hNormalAmount;
int g_iNormalAmount;
ConVar g_hWrAmount;
int g_iWrAmount;
ConVar g_hPBAmount;
int g_iPBAmount;


char gS_Map[160];
int iTier;
int istyle;
float fpb;

public void OnPluginStart()
{
	
	CreateConVar("shavit_creds_version", PLUGIN_VERSION, "Zephyrus-Store : Shavit Credits Map Finish", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_hNormalEnabled = CreateConVar("credits_enable_normal", "1", "Store money give for map finish is enabled?", 0, true, 0.0, true, 1.0);
	g_hWREnabled = CreateConVar("credits_enable_wr", "1", "Store money given for map World Record is enabled?", 0, true, 0.0, true, 1.0);
	g_hEnabledPb = CreateConVar("credits_enable_pb", "1", "Store money given for map Personal Best is enabled?", 0, true, 0.0, true, 1.0);
	g_hT1Enabled = CreateConVar("credits_enable_t1", "1", "Enable/Disable give credits for Tier 1 Has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_hNormalAmount = CreateConVar("credits_amount_normal", "10", "Amount of credits are given on map finish.", 0, true, 1.0, false);
	g_hWrAmount = CreateConVar("credits_amount_wr", "25", "Amount of credits are given on breaking world records.", 0, true, 1.0, false);
	g_hPBAmount = CreateConVar("credits_amount_pb", "10", "Amount of credits are given on breaking your personal best.", 0, true, 1.0, false);
	
	AutoExecConfig(true, "shavit-credits");
}

public void OnConfigsExecuted() {
	g_iNormalEnabled = GetConVarInt(g_hNormalEnabled);
	g_iWREnabled = GetConVarInt(g_hWREnabled);
	g_iPBEnabled = GetConVarInt(g_hEnabledPb);
	g_iT1Enabled = GetConVarInt(g_hT1Enabled);
	g_iNormalAmount = GetConVarInt(g_hNormalAmount);
	g_iWrAmount = GetConVarInt(g_hWrAmount);
	g_iPBAmount = GetConVarInt(g_hPBAmount);
}

public void OnMapStart()
{
	GetCurrentMap(gS_Map, 160);
	GetMapDisplayName(gS_Map, gS_Map, 160);
	iTier = Shavit_GetMapTier(gS_Map);		
}

public Action Shavit_OnStart(int client, int track)
{
	istyle = Shavit_GetBhopStyle(client);
	fpb = Shavit_GetClientPB(client, istyle, track);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int track)
{
	
	if(g_iNormalEnabled == 1)
	{
		if(g_iT1Enabled == 1 || iTier != 1)
		{
			int fcredits = GetConVarInt(g_hNormalAmount)*iTier;
	
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for finishing this map.", fcredits);
		}
	}
	
	if(g_iPBEnabled == 1)
	{	
			if(time<fpb){
			
				int fcredits = GetConVarInt(g_hPBAmount)*iTier;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
				PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for breaking your Personal Best.", fcredits);
			}
	}
	
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int track)
{
	if(g_iWREnabled == 1)
	{
			int fcredits = GetConVarInt(g_hWrAmount)*iTier;
	
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for break the world records.", fcredits);
	}
}
