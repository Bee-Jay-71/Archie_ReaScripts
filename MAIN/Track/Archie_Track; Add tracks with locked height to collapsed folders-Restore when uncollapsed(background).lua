--[[
   * Category:    Track
   * Description: Add tracks with locked height to collapsed folders-Restore when uncollapsed(background)
   * Author:      Archie
   * Version:     1.06
   * AboutScript: ---
   * О скрипте:   Добавить треки с заблокированной высотой в свернутые папки / восстановить, когда не свернуто - фон
   * GIF:         http://archiescript.github.io/ReaScriptSiteGif/html/AddTracksWithLockedHeightToCollapsedFolders.html
   *              https://avatars.mds.yandex.net/get-pdb/1686358/80792b21-62fc-4ae6-8fc0-23e0e8a942ce/orig
   *              https://avatars.mds.yandex.net/get-pdb/1884734/e0a1d375-0a1b-4a86-821a-1bc23bcb8926/orig
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * DONATION:    http://paypal.me/ReaArchie?locale.x=ru_RU
   * Customer:    YuriOl / smrz1:[RMM];
   * Gave idea:   YuriOl / smrz1:[RMM];
   * Changelog:
   *              v.1.04 [03062019]
   *                  + fixed bug - Remove - make the project dirty at the start of the script
   *                  + исправлена ошибка - Убрать - сделать проект грязный при старте скрипта

   *              v.1.03 [24052019]
   *                  + Remove - make the project dirty at the start of the script
   *                  + Убрать - сделать проект грязный при старте скрипта
   *              v.1.02 [11052019]
   *                Fixed bugs:
   *                  + With subfolders of the same level;
   *                  + Save state for different projects;
   *                  + Removed a window asking about saving the project;
   *                Исправлены ошибки:
   *                  +  С подпапками одного уровня;
   *                  +  Сохранение состояния для разных проектов;
   *                  +  Убрано окно с запросом о сохранении проекта;
   *              v.1.0 [07052019]
   *                Initialе;


   -- Тест только на windows  /  Test only on windows.
   --=======================================================================================
   --    SYSTEM REQUIREMENTS:           |  СИСТЕМНЫЕ ТРЕБОВАНИЯ:
   (+) - required for installation      | (+) - обязательно для установки
   (-) - not necessary for installation | (-) - не обязательно для установки
   -----------------------------------------------------------------------------------------
   (+) Reaper v.5.967 +           --| http://www.reaper.fm/download.php
   (+) SWS v.2.10.0 +             --| http://www.sws-extension.org/index.php
   (-) ReaPack v.1.2.2 +          --| http://reapack.com/repos
   (+) Arc_Function_lua v.2.4.1 + --| Repository - Archie-ReaScripts  http://clck.ru/EjERc
   (-) reaper_js_ReaScriptAPI     --| Repository - ReaTeam Extensions http://clck.ru/Eo5Nr or http://clck.ru/Eo5Lw
   (-) Visual Studio С++ 2015     --|  http://clck.ru/Eq5o6
   =======================================================================================]]






    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================




    --=========================================
    local function MODULE(file);
        local E,A=pcall(dofile,file);if not(E)then;reaper.ShowConsoleMsg("\n\nError - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMISSING FILE / ОТСУТСТВУЕТ ФАЙЛ!\n'..file:gsub('\\','/'))return;end;
        if not A.VersArcFun("2.8.5",file,'')then;A=nil;return;end;return A;
    end; local Arc = MODULE((reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    --=========================================
	




    local Api_sws = Arc.SWS_API(true);
    if not Api_sws then Arc.no_undo() return end;


    Arc.HelpWindowWhenReRunning(1,"Arc_Function_lua",false);

    local function main();

        function ScrName_f();
            return({reaper.get_action_context()})[2]:match(".+[/\\](.+)");
        end;

        local ProjPathName = ({reaper.EnumProjects(-1,"")})[2];
        local ProjectState2 = reaper.GetProjectStateChangeCount(0);
        local Table = {};
        local KeyEx = "Table";
        local TableMonTr2={};

        Arc.SetToggleButtonOnOff(1);
        -------------------
        local G_ExtState = ({reaper.GetProjExtState(0,ScrName_f(),KeyEx)})[2]..'&&&';
        if G_ExtState ~= "&&&" then;
            for var in string.gmatch(G_ExtState,"(.-)&&&")do;
                local ByGUIDExt = var:match("(%{.-%})");
                local Track = reaper.BR_GetMediaTrackByGUID(0,ByGUIDExt);
                if Track then;
                    local Depth = reaper.GetTrackDepth(Track);
                    if Depth > 0 then;
                        local Numb = reaper.GetMediaTrackInfo_Value(Track,"IP_TRACKNUMBER");
                        for i2 = Numb-2,0,-1 do;
                            local TrackPre = reaper.GetTrack(0,i2);
                            local FoldPre = reaper.GetMediaTrackInfo_Value(TrackPre,"I_FOLDERDEPTH");
                            if FoldPre == 1 then;
                                local DepthPre = reaper.GetTrackDepth(TrackPre);
                                if DepthPre < Depth then;
                                    Depth = DepthPre;
                                    local Collaps = reaper.GetMediaTrackInfo_Value(TrackPre,"I_FOLDERCOMPACT");
                                    if Collaps == 2 then;
                                        table.insert(Table,var);
                                    end;
                                end;
                                if DepthPre == 0 then break end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        -----------


        local function loop();

            local ProjectState = reaper.GetProjectStateChangeCount(0);
            if ProjectState ~= ProjectState2 then;
                ProjectState2 = ProjectState;

                -----------------
                local AdjustWind;
                local i = 1;
                while(true)do;
                    local Track = reaper.GetTrack(0,i-1);
                    if Track then;
                        local Fold = reaper.GetMediaTrackInfo_Value(Track,"I_FOLDERDEPTH");
                        if Fold == 1 then;
                            local Collaps = reaper.GetMediaTrackInfo_Value(Track,"I_FOLDERCOMPACT");
                            if Collaps == 2 then;
                                local Depth = reaper.GetTrackDepth(Track);
                                local Numb = reaper.GetMediaTrackInfo_Value(Track,"IP_TRACKNUMBER");
                                ----
                                for i2 = Numb, reaper.CountTracks(0)-1 do;
                                    local TrackChild = reaper.GetTrack(0,i2);
                                    local DepthChild = reaper.GetTrackDepth(TrackChild);
                                    if DepthChild > Depth then;
                                        ---------
                                        local heightCast = reaper.GetMediaTrackInfo_Value(TrackChild,"I_HEIGHTOVERRIDE");
                                        local  heightLock = reaper.GetMediaTrackInfo_Value(TrackChild,"B_HEIGHTLOCK");

                                        if heightCast > 0 and heightLock > 0 then;
                                            --reaper.SetMediaTrackInfo_Value(TrackChild,"I_HEIGHTOVERRIDE",0);
                                            reaper.SetMediaTrackInfo_Value(TrackChild,"B_HEIGHTLOCK",0);

                                            local GUID = reaper.GetTrackGUID(TrackChild);
                                            Table[#Table+1] = GUID..";heightCast("..heightCast..");heightLock("..heightLock..");";
                                            AdjustWind = 1;
                                        end;
                                        ---------
                                    else;
                                        local NumbNext = (reaper.GetMediaTrackInfo_Value(TrackChild,"IP_TRACKNUMBER")-1);
                                        i = NumbNext;
                                        break;
                                    end;
                                end;
                                ---
                            end;
                        end;
                    else;
                        break;
                    end;
                    if AdjustWind then;
                        reaper.TrackList_AdjustWindows(true);
                    end;
                    AdjustWind = nil;
                    i=i+1;
                    if i == 100000 then return end;
                end;
                -------------------


                -------------------
                if #Table > 0 then;
                    for i = #Table,1,-1 do;
                        local ByGUID,HeightCast,HeightLock = Table[i]:match("(%{.-%}).+%((.+)%).+%((.+)%)");
                        local Track = reaper.BR_GetMediaTrackByGUID(0,ByGUID);
                        if Track then;
                            local Depth = reaper.GetTrackDepth(Track);
                            local Numb = reaper.GetMediaTrackInfo_Value(Track,"IP_TRACKNUMBER");
                            if Depth > 0 then;
                                for i2 = Numb-2,0,-1 do;
                                    local TrackPre = reaper.GetTrack(0,i2);
                                    local FoldPre = reaper.GetMediaTrackInfo_Value(TrackPre,"I_FOLDERDEPTH");
                                    if FoldPre == 1 then;
                                        local DepthPre = reaper.GetTrackDepth(TrackPre);
                                        if DepthPre < Depth then;
                                            Depth = DepthPre;
                                            local Collaps = reaper.GetMediaTrackInfo_Value(TrackPre,"I_FOLDERCOMPACT");
                                            if Collaps == 2 then break end;
                                            if Collaps ~= 2 and DepthPre == 0 or DepthPre == 0 then;---
                                                reaper.SetMediaTrackInfo_Value(Track,"B_HEIGHTLOCK",HeightLock);
                                                reaper.SetMediaTrackInfo_Value(Track, "I_HEIGHTOVERRIDE",HeightCast);
                                                table.remove (Table,i);
                                                AdjustWind = 1;
                                                break;
                                            end;
                                            if DepthPre == 0 then break end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        if AdjustWind then;
                            reaper.TrackList_AdjustWindows(true);
                        end;
                        AdjustWind = nil;
                    end;
                end;
                --------------------

                --------------------
                local TableMonTr1 = {};
                for i = 1, reaper.CountTracks(0) do;
                    local Track = reaper.GetTrack(0,i-1);
                    local GUID = reaper.GetTrackGUID(Track);
                    local Collaps = reaper.GetMediaTrackInfo_Value(Track,"I_FOLDERCOMPACT");
                    local He_Lock = reaper.GetMediaTrackInfo_Value(Track,"B_HEIGHTLOCK");
                    TableMonTr1[i]= GUID.."&"..Collaps.."&"..He_Lock;
                end;
                local ComTabl = ComparedTwoTables(TableMonTr1, TableMonTr2);
                if not ComTabl then;
                    ---

                    local ProjPathName2 = ({reaper.EnumProjects(-1,"")})[2];
                    if ProjPathName2 ~= ProjPathName then;
                        dofile(({reaper.get_action_context()})[2]) return;
                    end;
                    reaper.SetProjExtState(0,ScrName_f(),KeyEx,table.concat(Table,'&&&'));
                    reaper.MarkProjectDirty(0);
                    ---
                    TableMonTr2 = TableMonTr1;
                end;
                --------------------

                A_counter=(A_counter or 0)+1;
            end;
            reaper.defer(loop);
        end;
        loop();
    end;


    -------- / Сравнить две таблицы / --------
    function ComparedTwoTables(table1, table2);
        if #table1 ~= #table2 then return false end;
        for key, val in pairs(table1) do;
            if table2[key] ~= val then;
                return false;
            end;
        end;
        for key, val in pairs(table2) do;
            if table1[key] ~= val then;
                return false;
            end;
        end;
        return true;
    end;
    ------------------------------------------


    main();

    reaper.atexit(
        function();Arc.SetToggleButtonOnOff(0);
        end
        );