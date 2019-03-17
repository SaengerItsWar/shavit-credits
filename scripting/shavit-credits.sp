#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>

#define PLUGIN_VERSION "1.2"
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store",
	author = "Farhannz, Modified by Saengerkrieg12",
	description = "Gives Zephyrus Store Credits when map finish, break records",
	version = "1.2",
	url = "https://github.com/Saengerkrieg12/shavit-credits"
};
Handle gH_Enabled_normal;
Handle gH_Enabled_wr;
Handle gH_Enabled_pb;
Handle gH_Enabled_top;
Handle gH_Amount_normal;
Handle gH_Amount_wr;
Handle gH_Amount_pb;
Handle gH_Amount_top;
char gS_Map[160];
int iTier;

public void OnPluginStart()
{
	CreateConVar("shavit_creds_version", PLUGIN_VERSION, "Zephyrus-Store : Shavit Credits Map Finish", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	gH_Enabled_normal = CreateConVar("credits_enable_normal", "1", "Store money give for map finish is enabled?", 0, true, 0.0, true, 1.0);
	gH_Enabled_wr = CreateConVar("credits_enable_wr", "1", "Store money given for map World Record is enabled?", 0, true, 0.0, true, 1.0);
	gH_Enabled_pb = CreateConVar("credits_enable_pb", "1", "Store money given for map Personal Best is enabled?", 0, true, 0.0, true, 1.0);
	gH_Enabled_top = CreateConVar("credits_enable_top", "1", "Store money given for map TOP 10 is enabled?", 0, true, 0.0, true, 1.0);
	gH_Amount_normal = CreateConVar("credits_amount_normal", "10", "Amount of credits are given on map finish.", 0, true, 1.0, false);
	gH_Amount_wr = CreateConVar("credits_amount_wr", "125", "Amount of credits are given on breaking world records.", 0, true, 1.0, false);
	gH_Amount_pb = CreateConVar("credits_amount_pb", "10", "Amount of credits are given on breaking your personal best.", 0, true, 1.0, false);
	gH_Amount_top = CreateConVar("credits_amount_pb", "10", "Amount of credits are given on breaking your personal best.", 0, true, 1.0, false);
	
	AutoExecConfig(true, "shavit-credits");
	
}
public void OnMapStart()
{
	GetCurrentMap(gS_Map, 160);
	GetMapDisplayName(gS_Map, gS_Map, 160);
	iTier = Shavit_GetMapTier(gS_Map);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int track)
{
	float fClientTime = time;
	float fClientPB = Shavit_GetClientPB(client, style, track);
	int iClientRank = Shavit_GetRankForTime(style, time, track);
	if(gH_Enabled_normal)
	{
		int fcredits = GetConVarInt(gH_Amount_normal)*iTier;
	
		Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "Shavit-Credits: Finish Map.");
		PrintToChat(client, "\x04[wAVE-Store]\x01 You have earned \x04%d\x01 credits for finishing this map.", fcredits);
	}
	if(gH_Enabled_pb)
	{	
		if(fClientPB<fClientTime){
			
			int fcredits = GetConVarInt(gH_Amount_pb)*iTier;
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "Shavit-Credits: New Personal Best.");
			PrintToChat(client, "\x04[wAVE-Store]\x01 You have earned \x04%d\x01 credits for breaking your Personal Best.", fcredits);
		}
	}

	if(gH_Enabled_top)
	{
		if(iClientRank <= 10)
		{
			int fcredits = GetConVarInt(gH_Amount_top)*iTier;
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "Shavit-Credits: has a Time inside the Top 10.");
			PrintToChat(client, "\x04[Store]\x01 You have earned \x04%d\x01 credits for beeing in the Top10.", fcredits);
		}
	}
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps)
{
	if(gH_Enabled_wr)
	{
		int fcredits = GetConVarInt(gH_Amount_wr)*iTier;
	
		Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "Shavit-Credits: New Map WR.");
		PrintToChat(client, "\x04[Store]\x01 You have earned \x04%d\x01 credits for break the world records.", fcredits);
	}
}