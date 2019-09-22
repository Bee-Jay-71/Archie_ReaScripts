--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Edit cursor
   * Features:    Startup
   * Description: Move edit cursor to last start of play cursor
   * Author:      Archie
   * Version:     1.0
   * Описание:    Переместить курсор редактирования на последний старт  плей курсора 
   * GIF:         ---
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * Customer:    Eq Tunkul(Rmm)
   * Gave idea:   Eq Tunkul(Rmm)
   * Extension:   
   *              Reaper 5.983+ http://www.reaper.fm/
   *              Arc_Function_lua v.2.6.3+  (Repository: Archie-ReaScripts) http://clck.ru/EjERc
   * Changelog:   v.1.0 [21.09.19]
   *                  + initialе
--]]
    
    
    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================
    
    
    local
    ChangePosition = 1;
                -- = 0 Не менять позицию при перемещении курсора при воспроизведении
                -- = 1 Поменять позицию при перемещении курсора при воспроизведении
                       ------------------------------------------------------------
                -- = 0 Do not change position when moving the cursor during playback
                -- = 1 Change position when moving cursor during playback
                ---------------------------------------------------------
    
    
    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================
    
    
    
    --============== FUNCTION MODULE FUNCTION ========================= FUNCTION MODULE FUNCTION ============== FUNCTION MODULE FUNCTION ==============
    local Fun,Load,Arc = reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions'; Load,Arc = pcall(dofile,Fun..'/Arc_Function_lua.lua');--====
    if not Load then reaper.RecursiveCreateDirectory(Fun,0);reaper.MB('Missing file / Отсутствует файл !\n\n'..Fun..'/Arc_Function_lua.lua',"Error",0);
    return end; if not Arc.VersionArc_Function_lua("2.6.3",Fun,"")then Arc.no_undo() return end;--=====================================================
    --============== FUNCTION MODULE FUNCTION ======▲=▲=▲============== FUNCTION MODULE FUNCTION ============== FUNCTION MODULE FUNCTION ============== 
    
    
    
    local title = "Move edit cursor to last start of play cursor";
    local is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context();
    local extname = filename:match(".+[/\\](.+)");
    local stopDoubleScr,ActiveDoubleScr;
    local PlayPos_2;
    
    
    local function loop();
        ----- stop Double Script -------
        if not ActiveDoubleScr then;
            stopDoubleScr = (tonumber(reaper.GetExtState(extname,"stopDoubleScr"))or 0)+1;
            reaper.SetExtState(extname,"stopDoubleScr",stopDoubleScr,false);
            ActiveDoubleScr = true;
        end;
        
        local stopDoubleScr2 = tonumber(reaper.GetExtState(extname,"stopDoubleScr"));
        if stopDoubleScr2 > stopDoubleScr then return end;
        -----------------------------------------------
        
        -----------------------------------------------
        local PlayState = reaper.GetPlayState()&1;
        local PlayPos = reaper.GetPlayPosition();
        local PlayStart = tonumber(({reaper.GetProjExtState(0,extname,"PlayStart")})[2]);
        -----------------------------------------------
        
        ----Поменять позицию при перемещении курсора---
        if ChangePosition == 1 then;
            if not PlayPos_2 then PlayPos_2 = PlayPos end;
            if (PlayPos_2 > PlayPos+0.5 or PlayPos_2 < PlayPos-0.5) and PlayStart then;
                reaper.SetProjExtState(0,extname,"PlayStart","");
                --t3=(t3 or 0)+1
            end;
            PlayPos_2 = PlayPos;
        end;
        -----------------------------------------------
        
        -----------------------------------------------
        if PlayState == 1 and not PlayStart then;
            local PlayStartPos = reaper.GetPlayPosition();
            reaper.SetProjExtState(0,extname,"PlayStartPos",PlayStartPos);
            reaper.SetProjExtState(0,extname,"PlayStart",PlayStartPos);
            --t1=(t1 or 0)+1
        elseif PlayState == 0 and PlayStart then;
            reaper.SetProjExtState(0,extname,"PlayStart","");
            --t2=(t2 or 0)+1
        end;
        -----------------------------------------------
        reaper.defer(loop);
    end;
    
    
    
    ---___-----------------------------------------------
    --reaper.DeleteExtState(extname,"FirstRun",false);
    local FirstRun = reaper.GetExtState(extname,"FirstRun")=="";
    if FirstRun then;
        reaper.SetExtState(extname,"FirstRun",1,false);
    end;
    -----------------------------------------------------
    
    
    loop();
    
    
    -----------------------------------------------------
    if not FirstRun then;
        Arc.HelpWindowWhenReRunning(2,"Arc_Function_lua",false,"/ "..extname);
        local ExtState = tonumber(({reaper.GetProjExtState(0,extname,"PlayStartPos")})[2]);
        if ExtState then;
            reaper.Undo_BeginBlock();
            reaper.SetEditCurPos(ExtState,true,false);
            reaper.Undo_EndBlock(title,-1);
        end;
    end;
    
    
    ---___-----------------------------------------------
    local scriptPath,scriptName = filename:match("(.+)[/\\](.+)");
    local id = Arc.GetIDByScriptName(scriptName,scriptPath);
    if id == -1 or type(id) ~= "string" then Arc.no_undo()return end;
    Arc.StartupScript(scriptName,id);
    -----------------------------------------------------