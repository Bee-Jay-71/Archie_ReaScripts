--[[
   * Category:    Take
   * Description: Paste color to selected item active take
   * Author:      Archie
   * Version:     1.01
   * AboutScript: Paste color to selected item active take
   * О скрипте:   Вставить цвет в выбранные элементы в активные тейки
                  скопировать с помощью:          
								        Copy color item active take
   * GIF:         ---
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * Donation:    http://money.yandex.ru/to/410018003906628
   * Customer:    YuriOl(RMM)
   * Gave idea:   YuriOl(RMM)
   * Changelog:   +  initialе / v.1.0 [17.01.2019]
   
   ===========================================================================================\
   -------------SYSTEM REQUIREMENTS:-------/-------СИСТЕМНЫЕ ТРЕБОВАНИЯ:----------------------|
   ===========================================================================================|
   + Reaper v.5.963 -----------| http://www.reaper.fm/download.php -------|(and above |и выше)|
   + SWS v.2.9.7 --------------| http://www.sws-extension.org/index.php --|(and above |и выше)|
   - ReaPack v.1.2.2 ----------| http://reapack.com/repos ----------------|(and above |и выше)|
   + Arc_Function_lua v.2.1.7 -| Repository - Archie-ReaScripts  http://clck.ru/EjERc |и выше)|
   - reaper_js_ReaScriptAPI64 -| Repository - ReaTeam Extensions http://clck.ru/Eo5Nr |и выше)|
                                                                 http://clck.ru/Eo5Lw |и выше)|
   - Visual Studio С++ 2015 ---| --------- http://clck.ru/Eq5o6 ----------|(and above |и выше)|
--===========================================================================================]]




    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================



    local reset = 0 
             -- = 0 | НЕ СБРАСЫВАТЬ СОХРАНЕНИЕ ПРИ ВОСТАНОВЛЕНИИ
             -- = 1 | СБРОСИТЬ СОХРАНЕНИЕ ПРИ ВОСТАНОВЛЕНИИ
                


    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================




    --======================================= FUNCTION MODULE FUNCTION =============================================================
    local Path,Mod,T,Way = reaper.GetResourcePath()--================== FUNCTION MODULE FUNCTION ===================================
    T = {Path..'\\Scripts\\Archie-ReaScripts\\Functions',(select(2,reaper.get_action_context()):match("(.+)[\\]")),Path};--=========
    for i=1,#T do;for j=0,math.huge do;Mod=reaper.EnumerateFiles(T[i],j);--=========================================================
        if Mod=="Arc_Function_lua.lua"then Way=T[i]break end;if not Mod then break end;end;if Way then break end;--=================
    end;if not Way then reaper.MB ('Missing file "Arc_Function_lua",\nDownload from repository Archie-ReaScript and put in \n'..T[1]
    ..'\n\nОтсутствует файл "Arc_Function_lua",\nСкачайте из репозитория Archie-ReaScript и поместите в \n'..T[1],"Error.",0)else;--
    package.path = package.path..";"..Way.."/?.lua";Arc=require"Arc_Function_lua";Arc.VersionArc_Function_lua("2.1.8",Way,"")end;---
    --=========================================================================================================▲▲▲▲▲================





    local Count_sel_item = reaper.CountSelectedMediaItems(0);
    if Count_sel_item == 0 then Arc.no_undo() return end;
    
    
    local HasExtState = reaper.HasExtState("{section_Arc¶Copy¶Color¶Take_ѨڢᴂX}","{key_Arc¶Copy¶Color¶Take_ѨڢᴂX}");
    if not HasExtState then Arc.no_undo() return end;

    reaper.Undo_BeginBlock();

    local Col = reaper.GetExtState("{section_Arc¶Copy¶Color¶Take_ѨڢᴂX}","{key_Arc¶Copy¶Color¶Take_ѨڢᴂX}");
    for i = 1, Count_sel_item do;
        local SelItem = reaper.GetSelectedMediaItem(0,i-1);
        local ActiveTake = reaper.GetActiveTake(SelItem);
        reaper.SetMediaItemTakeInfo_Value(ActiveTake,"I_CUSTOMCOLOR",Col);
    end;
    if reset ~= 0 then;
        reaper.DeleteExtState("{section_Arc¶Copy¶Color¶Take_ѨڢᴂX}","{key_Arc¶Copy¶Color¶Take_ѨڢᴂX}",false);
    end;
    reaper.Undo_EndBlock('Paste color to selected item active take',-1);
    reaper.UpdateArrange();
 
    