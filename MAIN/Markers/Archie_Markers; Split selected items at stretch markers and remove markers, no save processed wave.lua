--[[
   * Category:    Markers
   * Description: Split selected items at stretch markers and remove markers, no save processed wave
   * Author:      Archie
   * Version:     1.04
   * AboutScript: Split selected items at stretch markers and remove markers, no save processed wave
   * О скрипте:   Разделить выбранные элементы на маркеры растяжения и удалить маркеры,
   *                                                              без сохранения обработанной волны
   * GIF:         ---
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * Donation:    http://money.yandex.ru/to/410018003906628
   * DONATION:    http://paypal.me/ReaArchie?locale.x=ru_RU
   * Customer:    borisuperful(Rmm/forum)
   * Gave idea:   borisuperful(Rmm/forum)
   * Changelog:   +  Fixed paths for Mac/ v.1.02 [29.01.19]
   *              +  Исправлены пути для Mac/ v.1.02 [29.01.19]

   *              + initialе / v.1.0 [011218]

   ===========================================================================================\
   -------------SYSTEM REQUIREMENTS:-------/-------СИСТЕМНЫЕ ТРЕБОВАНИЯ:----------------------|
   ===========================================================================================|
   + Reaper v.5.965 -----------| http://www.reaper.fm/download.php -------|(and above |и выше)|
   + SWS v.2.9.7 --------------| http://www.sws-extension.org/index.php --|(and above |и выше)|
   - ReaPack v.1.2.2 ----------| http://reapack.com/repos ----------------|(and above |и выше)|
   + Arc_Function_lua v.2.2.2 -| Repository - Archie-ReaScripts  http://clck.ru/EjERc |и выше)|
   - reaper_js_ReaScriptAPI64 -| Repository - ReaTeam Extensions http://clck.ru/Eo5Nr |и выше)|
                                                                 http://clck.ru/Eo5Lw |и выше)|
   - Visual Studio С++ 2015 ---| --------- http://clck.ru/Eq5o6 ----------|(and above |и выше)|
--===========================================================================================]]




    --=========================================================================================
    --/////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\\\
    --=========================================================================================




    --=========================================
    local function MODULE(file);
        local E,A=pcall(dofile,file);if not(E)then;reaper.ShowConsoleMsg("\n\nError - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMISSING FILE / ОТСУТСТВУЕТ ФАЙЛ!\n'..file:gsub('\\','/'))return;end;
        if not A.VersArcFun("2.8.5",file,'')then;A=nil;return;end;return A;
    end; local Arc = MODULE((reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    --=========================================
	





    local CountSelItem = reaper.CountSelectedMediaItems(0);
    if CountSelItem == 0 then Arc.no_undo() return end;

    local Undo;
    reaper.PreventUIRefresh(1);
    for j = CountSelItem-1,0,-1 do;

        local SelItem = reaper.GetSelectedMediaItem(0,j);
        local ActiveTake = reaper.GetActiveTake(SelItem);
        local NumStrMar = reaper.GetTakeNumStretchMarkers(ActiveTake);
        if NumStrMar > 0 then;
            if not Undo then;
                reaper.Undo_BeginBlock();
                Undo = "Active";
            end;
            ---
            local pos,SplIt,ItemGUID = {},{[1]=SelItem},{};
            local posIt = Arc.GetMediaItemInfo_Value(SelItem,"D_POSITION");
            local PlayRate = reaper.GetMediaItemTakeInfo_Value(ActiveTake,"D_PLAYRATE")
            for i = 1,NumStrMar do;
                pos[i] = posIt+select(2,reaper.GetTakeStretchMarker(ActiveTake,i-1))/PlayRate;
            end;
            ---
            for i = #pos,1,-1 do;
                SplIt[#SplIt+1] = reaper.SplitMediaItem(SelItem,pos[i]);
            end;
            ---
            for i = 1, #SplIt do;
                ItemGUID[i] = reaper.BR_GetMediaItemGUID(SplIt[i]);
            end;
            ---
            for i = 1,#ItemGUID do;
                local ItemByG = reaper.BR_GetMediaItemByGUID(0,ItemGUID[i]);
                local ActiveTake = reaper.GetActiveTake(ItemByG);
                local NumStrMar = reaper.GetTakeNumStretchMarkers(ActiveTake);
                reaper.DeleteTakeStretchMarkers(ActiveTake,0,NumStrMar);
            end;
        end;
    end;
    ---
    if Undo then;
        local UndoPoint = "Split selected items at stretch markers and remove markers, no save processed wave"
        reaper.Undo_EndBlock(UndoPoint,-1);
    else;
        Arc.no_undo();
    end;
    reaper.PreventUIRefresh(-1);
    reaper.UpdateArrange();