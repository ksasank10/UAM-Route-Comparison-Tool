classdef routecomparisontool_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ResultsPanel                    matlab.ui.container.Panel
        rec_text                        matlab.ui.control.TextArea
        Label_17                        matlab.ui.control.Label
        RecommendationLabel             matlab.ui.control.Label
        metrics_table                   matlab.ui.control.TextArea
        Label_16                        matlab.ui.control.Label
        winner_lbl                      matlab.ui.control.Label
        estol_score_lbl                 matlab.ui.control.Label
        eSTOLScoreLabel                 matlab.ui.control.Label
        evtol_score_lbl                 matlab.ui.control.Label
        eVTOLScoreLabel                 matlab.ui.control.Label
        AnalysisResultsPanel            matlab.ui.container.Panel
        axes_range                      matlab.ui.control.UIAxes
        axes_scores                     matlab.ui.control.UIAxes
        axes_soc                        matlab.ui.control.UIAxes
        axes_power                      matlab.ui.control.UIAxes
        MissionandRouteParametersPanel  matlab.ui.container.Panel
        status_lbl                      matlab.ui.control.Label
        run_btn                         matlab.ui.control.Button
        estol_ar                        matlab.ui.control.Spinner
        Spinner_16Label                 matlab.ui.control.Label
        AspectRatioLabel_2              matlab.ui.control.Label
        estol_swing                     matlab.ui.control.Spinner
        Spinner_15Label                 matlab.ui.control.Label
        WingareamLabel_2                matlab.ui.control.Label
        estol_batt                      matlab.ui.control.Spinner
        Spinner_14Label                 matlab.ui.control.Label
        BatterykWhLabel_2               matlab.ui.control.Label
        estol_mtow                      matlab.ui.control.Spinner
        Spinner_13Label                 matlab.ui.control.Label
        MTOWkgLabel_2                   matlab.ui.control.Label
        eSTOLPARAMTERSLabel             matlab.ui.control.Label
        evtol_ar                        matlab.ui.control.Spinner
        Label_12                        matlab.ui.control.Label
        AspectRatioLabel                matlab.ui.control.Label
        evtol_swing                     matlab.ui.control.Spinner
        Label_11                        matlab.ui.control.Label
        WingareamLabel                  matlab.ui.control.Label
        evtol_batt                      matlab.ui.control.Spinner
        Label_10                        matlab.ui.control.Label
        BatterykWhLabel                 matlab.ui.control.Label
        evtol_mtow                      matlab.ui.control.Spinner
        Label_9                         matlab.ui.control.Label
        MTOWkgLabel                     matlab.ui.control.Label
        eVTOLPARAMTERSLabel             matlab.ui.control.Label
        reserve_spinner                 matlab.ui.control.Spinner
        Label_8                         matlab.ui.control.Label
        ReserveLabel                    matlab.ui.control.Label
        hover_spinner                   matlab.ui.control.Spinner
        Label_7                         matlab.ui.control.Label
        HoverTimesLabel                 matlab.ui.control.Label
        climb_spinner                   matlab.ui.control.Spinner
        Label_6                         matlab.ui.control.Label
        ClimbRatemsLabel                matlab.ui.control.Label
        payload_spinner                 matlab.ui.control.Spinner
        Label_5                         matlab.ui.control.Label
        PayloadkgLabel                  matlab.ui.control.Label
        MISSIONLabel                    matlab.ui.control.Label
        ROUTELabel                      matlab.ui.control.Label
        offset_spinner                  matlab.ui.control.Spinner
        Label_4                         matlab.ui.control.Label
        eSTOLRunwayLengthmLabel         matlab.ui.control.Label
        speed_spinner                   matlab.ui.control.Spinner
        Label_3                         matlab.ui.control.Label
        CruiseSpeedmsLabel              matlab.ui.control.Label
        alt_spinner                     matlab.ui.control.Spinner
        Label_2                         matlab.ui.control.Label
        CruiseAltitudemLabel            matlab.ui.control.Label
        dist_spinner                    matlab.ui.control.Spinner
        Label                           matlab.ui.control.Label
        RouteDistancekmLabel            matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.Position = [35, 30, 1210, 740];
            [ev_in, es_in, rt] = default_params();

            % Route fields
            app.dist_spinner.Value    = rt.distance_km;
            app.alt_spinner.Value     = rt.cruise_alt_m;
            app.speed_spinner.Value   = rt.cruise_speed_ms;
            app.offset_spinner.Value  = rt.estol_offset_km;
            app.payload_spinner.Value = rt.payload_kg;
            app.climb_spinner.Value   = rt.climb_rate_ms;
            app.hover_spinner.Value   = rt.hover_time_s;
            app.reserve_spinner.Value = rt.battery_reserve * 100;

            % eVTOL fields
            app.evtol_mtow.Value  = ev_in.MTOW;
            app.evtol_batt.Value  = ev_in.battery_kWh;
            app.evtol_swing.Value = ev_in.S_wing;
            app.evtol_ar.Value    = ev_in.AR;

            % eSTOL fields
            app.estol_mtow.Value  = es_in.MTOW;
            app.estol_batt.Value  = es_in.battery_kWh;
            app.estol_swing.Value = es_in.S_wing;
            app.estol_ar.Value    = es_in.AR;

            app.status_lbl.Text = 'Ready — press Run Analysis to start.';
        end

        % Button pushed function: run_btn
        function RunButtonPushedFcn(app, event)
            app.status_lbl.Text       = 'Building aircraft models...';
            app.run_btn.Enable        = 'off';
            drawnow;
        
            C = constants();
        
            % ------------------------------------------------------------------
            % Build route struct from UI fields
            % ------------------------------------------------------------------
            route.distance_m      = app.dist_spinner.Value    * 1e3;
            route.cruise_alt_m    = app.alt_spinner.Value;
            route.cruise_speed_ms = app.speed_spinner.Value;
            route.payload_kg      = app.payload_spinner.Value;
            route.climb_rate_ms   = app.climb_spinner.Value;
            route.descent_rate_ms = 2.0;
            route.hover_time_s    = app.hover_spinner.Value;
            route.battery_reserve = app.reserve_spinner.Value / 100;
            route.estol_offset_m  = app.offset_spinner.Value  * 1e3;
        
            % ------------------------------------------------------------------
            % Build aircraft structs from UI fields
            % ------------------------------------------------------------------
            try
                [ev_in, es_in, ~] = default_params();
        
                ev_in.MTOW        = app.evtol_mtow.Value;
                ev_in.battery_kWh = app.evtol_batt.Value;
                ev_in.S_wing      = app.evtol_swing.Value;
                ev_in.AR          = app.evtol_ar.Value;
        
                es_in.MTOW        = app.estol_mtow.Value;
                es_in.battery_kWh = app.estol_batt.Value;
                es_in.S_wing      = app.estol_swing.Value;
                es_in.AR          = app.estol_ar.Value;
        
                evtol = build_aircraft(ev_in);
                estol = build_aircraft(es_in);
            catch ME
                app.status_lbl.Text  = ['Input error: ' ME.message];
                app.run_btn.Enable   = 'on';
                return
            end
        
            % ------------------------------------------------------------------
            % Run mission simulations
            % ------------------------------------------------------------------
            app.status_lbl.Text = 'Running eVTOL simulation...'; drawnow;
            try
                m_e = mission_sim(evtol, route, C);
            catch ME
                app.status_lbl.Text = ['eVTOL sim error: ' ME.message];
                app.run_btn.Enable  = 'on';
                return
            end
        
            app.status_lbl.Text = 'Running eSTOL simulation...'; drawnow;
            try
                m_s = mission_sim(estol, route, C);
            catch ME
                app.status_lbl.Text = ['eSTOL sim error: ' ME.message];
                app.run_btn.Enable  = 'on';
                return
            end
        
            % ------------------------------------------------------------------
            % Score
            % ------------------------------------------------------------------
            app.status_lbl.Text = 'Computing scores...'; drawnow;
            scores = scoring_framework(m_e, m_s);
            [rec, ~] = recommendation_engine(scores, m_e, m_s, route);
        
            % ------------------------------------------------------------------
            % Update plots
            % ------------------------------------------------------------------
            app.status_lbl.Text = 'Updating plots...'; drawnow;
        
            % Plot 1: Power vs time
            cla(app.axes_power); hold(app.axes_power, 'on');
            plot(app.axes_power, m_e.t_full/60, m_e.P_full/1e3, 'b', 'LineWidth',1.5, 'DisplayName','eVTOL');
            plot(app.axes_power, m_s.t_full/60, m_s.P_full/1e3, 'r', 'LineWidth',1.5, 'DisplayName','eSTOL');
            xlabel(app.axes_power, 'Time [min]');
            ylabel(app.axes_power, 'Power [kW]');
            title(app.axes_power, 'Power vs time');
            legend(app.axes_power); grid(app.axes_power, 'on');
        
            % Plot 2: Battery SoC vs distance
            cla(app.axes_soc); hold(app.axes_soc, 'on');
            soc_e = 1 - cumtrapz(m_e.t_full, m_e.P_full) / (evtol.battery_J);
            soc_s = 1 - cumtrapz(m_s.t_full, m_s.P_full) / (estol.battery_J);
            plot(app.axes_soc, m_e.x_full/1e3, soc_e*100, 'b', 'LineWidth',1.5, 'DisplayName','eVTOL');
            plot(app.axes_soc, m_s.x_full/1e3, soc_s*100, 'r', 'LineWidth',1.5, 'DisplayName','eSTOL');
            yline(app.axes_soc, route.battery_reserve*100, 'k--', 'Reserve');
            xlabel(app.axes_soc, 'Range [km]');
            ylabel(app.axes_soc, 'SoC [%]');
            title(app.axes_soc, 'Battery SoC vs distance');
            legend(app.axes_soc); grid(app.axes_soc, 'on');
        
            % Plot 3: Category scores
            cla(app.axes_scores);
            cat_labels = {'Energy','Performance','Aero','Operational'};
            cat_fields = {'energy','performance','aero','operational'};
            se = zeros(1,4); ss = zeros(1,4);
            for i = 1:4
                se(i) = scores.evtol_category.(cat_fields{i});
                ss(i) = scores.estol_category.(cat_fields{i});
            end
            x = 1:4;
            bar(app.axes_scores, x-0.2, se, 0.35, 'FaceColor',[0.22 0.48 0.75], 'DisplayName','eVTOL');
            hold(app.axes_scores,'on');
            bar(app.axes_scores, x+0.2, ss, 0.35, 'FaceColor',[0.80 0.33 0.17], 'DisplayName','eSTOL');
            set(app.axes_scores, 'XTick', x, 'XTickLabel', cat_labels);
            ylabel(app.axes_scores, 'Weighted score [0-1]'); ylim(app.axes_scores, [0 1.1]);
            title(app.axes_scores, 'Category scores (weighted)');
            legend(app.axes_scores); grid(app.axes_scores, 'on');
        
            % Plot 4: Energy efficiency vs distance
            cla(app.axes_range); hold(app.axes_range, 'on');
            distances = 10:10:120;
            epk_e = zeros(size(distances)); epk_s = zeros(size(distances));
            for i = 1:length(distances)
                r2 = route; r2.distance_m = distances(i)*1e3;
                me2 = mission_energy(evtol, r2, C);
                ms2 = mission_energy(estol, r2, C);
                epk_e(i) = me2.energy_per_km;
                epk_s(i) = ms2.energy_per_km;
            end
            plot(app.axes_range, distances, epk_e, 'b-o', 'LineWidth',1.5, 'MarkerSize',4, 'DisplayName','eVTOL');
            plot(app.axes_range, distances, epk_s, 'r-s', 'LineWidth',1.5, 'MarkerSize',4, 'DisplayName','eSTOL');
            xline(app.axes_range, route.distance_m/1e3, 'k--', 'This route', 'HandleVisibility','off');
            xlabel(app.axes_range, 'Distance [km]');
            ylabel(app.axes_range, 'Energy/km [kWh/km]');
            title(app.axes_range, 'Energy efficiency vs distance');
            legend(app.axes_range); grid(app.axes_range, 'on');
        
            % ------------------------------------------------------------------
            % Update right panel
            % ------------------------------------------------------------------
            app.evtol_score_lbl.Text = sprintf('%.3f', scores.evtol_total);
            app.estol_score_lbl.Text = sprintf('%.3f', scores.estol_total);
            app.winner_lbl.Text      = sprintf('Winner: %s  (+%.1f%%)', ...
                scores.winner, scores.margin*100);
        
            if strcmp(scores.winner, 'eVTOL')
                app.winner_lbl.FontColor = [0.2 0.5 0.8];
            else
                app.winner_lbl.FontColor = [0.8 0.3 0.2];
            end
        
            % Metrics table
            app.metrics_table.FontName = 'Courier New';
            app.metrics_table.FontSize = 12;
            tbl = sprintf('%-14s %5s %5s\n',  'Metric',          'eVTOL', 'eSTOL');
            tbl = [tbl repmat('-',1,26) newline];
            tbl = [tbl sprintf('%-14s %5.2f %5.2f\n', 'E/km[kWh]',  m_e.energy_per_km,      m_s.energy_per_km)];
            tbl = [tbl sprintf('%-14s %5.0f %5.0f\n', 'PeakPwr[kW]', m_e.peak_power_kW,      m_s.peak_power_kW)];
            tbl = [tbl sprintf('%-14s %5.1f %5.1f\n', 'SoC[%%]',     m_e.soc_at_landing*100, m_s.soc_at_landing*100)];
            tbl = [tbl sprintf('%-14s %5.1f %5.1f\n', 'Time[min]',   m_e.mission_time_s/60,  m_s.mission_time_s/60)];
            tbl = [tbl sprintf('%-14s %5.1f %5.1f\n', 'PeakL/D',     m_e.peak_LD,            m_s.peak_LD)];
            tbl = [tbl sprintf('%-14s %5.1f %5.1f\n', 'Dist[km]',    m_e.eff_dist_km,        m_s.eff_dist_km)];
            tbl = [tbl sprintf('%-14s %5.1f %5.1f\n', 'Energy[kWh]', m_e.energy_total_kWh,   m_s.energy_total_kWh)];
            app.metrics_table.Value = tbl;
        
            app.rec_text.Value   = rec;
            app.status_lbl.Text  = 'Analysis complete.';
            app.run_btn.Enable   = 'on';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [35 30 1210 740];
            app.UIFigure.Name = 'MATLAB App';

            % Create MissionandRouteParametersPanel
            app.MissionandRouteParametersPanel = uipanel(app.UIFigure);
            app.MissionandRouteParametersPanel.TitlePosition = 'centertop';
            app.MissionandRouteParametersPanel.Title = 'Mission and Route Parameters';
            app.MissionandRouteParametersPanel.FontWeight = 'bold';
            app.MissionandRouteParametersPanel.Position = [9 9 251 723];

            % Create RouteDistancekmLabel
            app.RouteDistancekmLabel = uilabel(app.MissionandRouteParametersPanel);
            app.RouteDistancekmLabel.FontSize = 11;
            app.RouteDistancekmLabel.FontWeight = 'bold';
            app.RouteDistancekmLabel.FontAngle = 'italic';
            app.RouteDistancekmLabel.Position = [9 650 138 19];
            app.RouteDistancekmLabel.Text = 'Route Distance [km]';

            % Create Label
            app.Label = uilabel(app.MissionandRouteParametersPanel);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [150 638 25 22];
            app.Label.Text = '';

            % Create dist_spinner
            app.dist_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.dist_spinner.Step = 5;
            app.dist_spinner.Limits = [5 300];
            app.dist_spinner.Tag = 'dist_spinner';
            app.dist_spinner.Position = [151 650 86 19];
            app.dist_spinner.Value = 50;

            % Create CruiseAltitudemLabel
            app.CruiseAltitudemLabel = uilabel(app.MissionandRouteParametersPanel);
            app.CruiseAltitudemLabel.FontSize = 11;
            app.CruiseAltitudemLabel.FontWeight = 'bold';
            app.CruiseAltitudemLabel.FontAngle = 'italic';
            app.CruiseAltitudemLabel.Position = [9 624 138 19];
            app.CruiseAltitudemLabel.Text = 'Cruise Altitude [m]';

            % Create Label_2
            app.Label_2 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.Position = [150 608 25 22];
            app.Label_2.Text = '';

            % Create alt_spinner
            app.alt_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.alt_spinner.Step = 50;
            app.alt_spinner.Limits = [100 1500];
            app.alt_spinner.Tag = 'alt_spinner';
            app.alt_spinner.Position = [151 624 86 19];
            app.alt_spinner.Value = 300;

            % Create CruiseSpeedmsLabel
            app.CruiseSpeedmsLabel = uilabel(app.MissionandRouteParametersPanel);
            app.CruiseSpeedmsLabel.FontSize = 11;
            app.CruiseSpeedmsLabel.FontWeight = 'bold';
            app.CruiseSpeedmsLabel.FontAngle = 'italic';
            app.CruiseSpeedmsLabel.Position = [9 598 138 19];
            app.CruiseSpeedmsLabel.Text = 'Cruise Speed [m/s]';

            % Create Label_3
            app.Label_3 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.Position = [150 578 25 22];
            app.Label_3.Text = '';

            % Create speed_spinner
            app.speed_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.speed_spinner.Step = 5;
            app.speed_spinner.Limits = [30 100];
            app.speed_spinner.Tag = 'speed_spinner';
            app.speed_spinner.Position = [151 598 86 19];
            app.speed_spinner.Value = 55;

            % Create eSTOLRunwayLengthmLabel
            app.eSTOLRunwayLengthmLabel = uilabel(app.MissionandRouteParametersPanel);
            app.eSTOLRunwayLengthmLabel.FontSize = 11;
            app.eSTOLRunwayLengthmLabel.FontWeight = 'bold';
            app.eSTOLRunwayLengthmLabel.FontAngle = 'italic';
            app.eSTOLRunwayLengthmLabel.Position = [9 572 160 19];
            app.eSTOLRunwayLengthmLabel.Text = 'eSTOL Runway Length [m]';

            % Create Label_4
            app.Label_4 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.Position = [150 548 25 22];
            app.Label_4.Text = '';

            % Create offset_spinner
            app.offset_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.offset_spinner.Step = 0.5;
            app.offset_spinner.Limits = [0 20];
            app.offset_spinner.Tag = 'offset_spinner';
            app.offset_spinner.Position = [172 572 66 19];
            app.offset_spinner.Value = 2;

            % Create ROUTELabel
            app.ROUTELabel = uilabel(app.MissionandRouteParametersPanel);
            app.ROUTELabel.HorizontalAlignment = 'center';
            app.ROUTELabel.FontWeight = 'bold';
            app.ROUTELabel.Position = [9 680 225 17];
            app.ROUTELabel.Text = 'ROUTE';

            % Create MISSIONLabel
            app.MISSIONLabel = uilabel(app.MissionandRouteParametersPanel);
            app.MISSIONLabel.HorizontalAlignment = 'center';
            app.MISSIONLabel.FontWeight = 'bold';
            app.MISSIONLabel.Position = [9 542 225 17];
            app.MISSIONLabel.Text = 'MISSION';

            % Create PayloadkgLabel
            app.PayloadkgLabel = uilabel(app.MissionandRouteParametersPanel);
            app.PayloadkgLabel.FontSize = 11;
            app.PayloadkgLabel.FontWeight = 'bold';
            app.PayloadkgLabel.FontAngle = 'italic';
            app.PayloadkgLabel.Position = [9 516 138 19];
            app.PayloadkgLabel.Text = 'Payload [kg]';

            % Create Label_5
            app.Label_5 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.Position = [150 483 25 22];
            app.Label_5.Text = '';

            % Create payload_spinner
            app.payload_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.payload_spinner.Step = 50;
            app.payload_spinner.Limits = [50 1000];
            app.payload_spinner.Tag = 'payload_spinner';
            app.payload_spinner.Position = [151 516 86 19];
            app.payload_spinner.Value = 400;

            % Create ClimbRatemsLabel
            app.ClimbRatemsLabel = uilabel(app.MissionandRouteParametersPanel);
            app.ClimbRatemsLabel.FontSize = 11;
            app.ClimbRatemsLabel.FontWeight = 'bold';
            app.ClimbRatemsLabel.FontAngle = 'italic';
            app.ClimbRatemsLabel.Position = [9 490 138 19];
            app.ClimbRatemsLabel.Text = 'Climb Rate [m/s]';

            % Create Label_6
            app.Label_6 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.Position = [150 453 25 22];
            app.Label_6.Text = '';

            % Create climb_spinner
            app.climb_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.climb_spinner.Step = 0.5;
            app.climb_spinner.Limits = [1 10];
            app.climb_spinner.Tag = 'climb_spinner';
            app.climb_spinner.Position = [151 490 86 19];
            app.climb_spinner.Value = 3;

            % Create HoverTimesLabel
            app.HoverTimesLabel = uilabel(app.MissionandRouteParametersPanel);
            app.HoverTimesLabel.FontSize = 11;
            app.HoverTimesLabel.FontWeight = 'bold';
            app.HoverTimesLabel.FontAngle = 'italic';
            app.HoverTimesLabel.Position = [9 465 138 19];
            app.HoverTimesLabel.Text = 'Hover Time [s]';

            % Create Label_7
            app.Label_7 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.Position = [150 423 25 22];
            app.Label_7.Text = '';

            % Create hover_spinner
            app.hover_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.hover_spinner.Step = 5;
            app.hover_spinner.Limits = [10 120];
            app.hover_spinner.Tag = 'hover_spinner';
            app.hover_spinner.Position = [151 465 86 19];
            app.hover_spinner.Value = 30;

            % Create ReserveLabel
            app.ReserveLabel = uilabel(app.MissionandRouteParametersPanel);
            app.ReserveLabel.FontSize = 11;
            app.ReserveLabel.FontWeight = 'bold';
            app.ReserveLabel.FontAngle = 'italic';
            app.ReserveLabel.Position = [9 439 138 19];
            app.ReserveLabel.Text = 'Reserve [%]';

            % Create Label_8
            app.Label_8 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_8.HorizontalAlignment = 'right';
            app.Label_8.Position = [150 393 25 22];
            app.Label_8.Text = '';

            % Create reserve_spinner
            app.reserve_spinner = uispinner(app.MissionandRouteParametersPanel);
            app.reserve_spinner.Step = 5;
            app.reserve_spinner.Limits = [10 40];
            app.reserve_spinner.Tag = 'reserve_spinner';
            app.reserve_spinner.Position = [151 439 86 19];
            app.reserve_spinner.Value = 20;

            % Create eVTOLPARAMTERSLabel
            app.eVTOLPARAMTERSLabel = uilabel(app.MissionandRouteParametersPanel);
            app.eVTOLPARAMTERSLabel.HorizontalAlignment = 'center';
            app.eVTOLPARAMTERSLabel.FontWeight = 'bold';
            app.eVTOLPARAMTERSLabel.Position = [9 404 225 17];
            app.eVTOLPARAMTERSLabel.Text = 'eVTOL PARAMTERS';

            % Create MTOWkgLabel
            app.MTOWkgLabel = uilabel(app.MissionandRouteParametersPanel);
            app.MTOWkgLabel.FontSize = 11;
            app.MTOWkgLabel.FontWeight = 'bold';
            app.MTOWkgLabel.FontAngle = 'italic';
            app.MTOWkgLabel.Position = [9 383 112 19];
            app.MTOWkgLabel.Text = 'MTOW [kg]';

            % Create Label_9
            app.Label_9 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.Position = [150 328 25 22];
            app.Label_9.Text = '';

            % Create evtol_mtow
            app.evtol_mtow = uispinner(app.MissionandRouteParametersPanel);
            app.evtol_mtow.Step = 100;
            app.evtol_mtow.Limits = [500 8000];
            app.evtol_mtow.Tag = 'evtol_mtow';
            app.evtol_mtow.Position = [125 383 112 19];
            app.evtol_mtow.Value = 2177;

            % Create BatterykWhLabel
            app.BatterykWhLabel = uilabel(app.MissionandRouteParametersPanel);
            app.BatterykWhLabel.FontSize = 11;
            app.BatterykWhLabel.FontWeight = 'bold';
            app.BatterykWhLabel.FontAngle = 'italic';
            app.BatterykWhLabel.Position = [9 357 112 19];
            app.BatterykWhLabel.Text = 'Battery [kWh]';

            % Create Label_10
            app.Label_10 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_10.HorizontalAlignment = 'right';
            app.Label_10.Position = [150 298 25 22];
            app.Label_10.Text = '';

            % Create evtol_batt
            app.evtol_batt = uispinner(app.MissionandRouteParametersPanel);
            app.evtol_batt.Step = 10;
            app.evtol_batt.Limits = [20 500];
            app.evtol_batt.Tag = 'evtol_batt';
            app.evtol_batt.Position = [125 357 112 19];
            app.evtol_batt.Value = 200;

            % Create WingareamLabel
            app.WingareamLabel = uilabel(app.MissionandRouteParametersPanel);
            app.WingareamLabel.FontSize = 11;
            app.WingareamLabel.FontWeight = 'bold';
            app.WingareamLabel.FontAngle = 'italic';
            app.WingareamLabel.Position = [9 331 112 19];
            app.WingareamLabel.Text = 'Wing area [m²]';

            % Create Label_11
            app.Label_11 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.Position = [150 268 25 22];
            app.Label_11.Text = '';

            % Create evtol_swing
            app.evtol_swing = uispinner(app.MissionandRouteParametersPanel);
            app.evtol_swing.Step = 0.5;
            app.evtol_swing.Limits = [3 50];
            app.evtol_swing.Tag = 'evtol_swing';
            app.evtol_swing.Position = [125 331 112 19];
            app.evtol_swing.Value = 10.7;

            % Create AspectRatioLabel
            app.AspectRatioLabel = uilabel(app.MissionandRouteParametersPanel);
            app.AspectRatioLabel.FontSize = 11;
            app.AspectRatioLabel.FontWeight = 'bold';
            app.AspectRatioLabel.FontAngle = 'italic';
            app.AspectRatioLabel.Position = [9 305 112 19];
            app.AspectRatioLabel.Text = 'Aspect Ratio';

            % Create Label_12
            app.Label_12 = uilabel(app.MissionandRouteParametersPanel);
            app.Label_12.HorizontalAlignment = 'right';
            app.Label_12.Position = [150 238 25 22];
            app.Label_12.Text = '';

            % Create evtol_ar
            app.evtol_ar = uispinner(app.MissionandRouteParametersPanel);
            app.evtol_ar.Step = 0.5;
            app.evtol_ar.Limits = [3 20];
            app.evtol_ar.Tag = 'evtol_ar';
            app.evtol_ar.Position = [125 305 112 19];
            app.evtol_ar.Value = 8.5;

            % Create eSTOLPARAMTERSLabel
            app.eSTOLPARAMTERSLabel = uilabel(app.MissionandRouteParametersPanel);
            app.eSTOLPARAMTERSLabel.HorizontalAlignment = 'center';
            app.eSTOLPARAMTERSLabel.FontWeight = 'bold';
            app.eSTOLPARAMTERSLabel.Position = [9 271 225 17];
            app.eSTOLPARAMTERSLabel.Text = 'eSTOL PARAMTERS';

            % Create MTOWkgLabel_2
            app.MTOWkgLabel_2 = uilabel(app.MissionandRouteParametersPanel);
            app.MTOWkgLabel_2.FontSize = 11;
            app.MTOWkgLabel_2.FontWeight = 'bold';
            app.MTOWkgLabel_2.FontAngle = 'italic';
            app.MTOWkgLabel_2.Position = [9 250 112 19];
            app.MTOWkgLabel_2.Text = 'MTOW [kg]';

            % Create Spinner_13Label
            app.Spinner_13Label = uilabel(app.MissionandRouteParametersPanel);
            app.Spinner_13Label.HorizontalAlignment = 'right';
            app.Spinner_13Label.Position = [150 173 25 22];
            app.Spinner_13Label.Text = '';

            % Create estol_mtow
            app.estol_mtow = uispinner(app.MissionandRouteParametersPanel);
            app.estol_mtow.Step = 100;
            app.estol_mtow.Limits = [500 8000];
            app.estol_mtow.Tag = 'estol_mtow';
            app.estol_mtow.Position = [125 250 112 19];
            app.estol_mtow.Value = 3175;

            % Create BatterykWhLabel_2
            app.BatterykWhLabel_2 = uilabel(app.MissionandRouteParametersPanel);
            app.BatterykWhLabel_2.FontSize = 11;
            app.BatterykWhLabel_2.FontWeight = 'bold';
            app.BatterykWhLabel_2.FontAngle = 'italic';
            app.BatterykWhLabel_2.Position = [9 224 112 19];
            app.BatterykWhLabel_2.Text = 'Battery [kWh]';

            % Create Spinner_14Label
            app.Spinner_14Label = uilabel(app.MissionandRouteParametersPanel);
            app.Spinner_14Label.HorizontalAlignment = 'right';
            app.Spinner_14Label.Position = [150 143 25 22];
            app.Spinner_14Label.Text = '';

            % Create estol_batt
            app.estol_batt = uispinner(app.MissionandRouteParametersPanel);
            app.estol_batt.Step = 10;
            app.estol_batt.Limits = [20 500];
            app.estol_batt.Tag = 'estol_batt';
            app.estol_batt.Position = [125 224 112 19];
            app.estol_batt.Value = 150;

            % Create WingareamLabel_2
            app.WingareamLabel_2 = uilabel(app.MissionandRouteParametersPanel);
            app.WingareamLabel_2.FontSize = 11;
            app.WingareamLabel_2.FontWeight = 'bold';
            app.WingareamLabel_2.FontAngle = 'italic';
            app.WingareamLabel_2.Position = [9 198 112 19];
            app.WingareamLabel_2.Text = 'Wing area [m²]';

            % Create Spinner_15Label
            app.Spinner_15Label = uilabel(app.MissionandRouteParametersPanel);
            app.Spinner_15Label.HorizontalAlignment = 'right';
            app.Spinner_15Label.Position = [150 113 25 22];
            app.Spinner_15Label.Text = '';

            % Create estol_swing
            app.estol_swing = uispinner(app.MissionandRouteParametersPanel);
            app.estol_swing.Step = 0.5;
            app.estol_swing.Limits = [5 150];
            app.estol_swing.Tag = 'estol_swing';
            app.estol_swing.Position = [125 198 112 19];
            app.estol_swing.Value = 30;

            % Create AspectRatioLabel_2
            app.AspectRatioLabel_2 = uilabel(app.MissionandRouteParametersPanel);
            app.AspectRatioLabel_2.FontSize = 11;
            app.AspectRatioLabel_2.FontWeight = 'bold';
            app.AspectRatioLabel_2.FontAngle = 'italic';
            app.AspectRatioLabel_2.Position = [9 172 112 19];
            app.AspectRatioLabel_2.Text = 'Aspect Ratio';

            % Create Spinner_16Label
            app.Spinner_16Label = uilabel(app.MissionandRouteParametersPanel);
            app.Spinner_16Label.HorizontalAlignment = 'right';
            app.Spinner_16Label.Position = [150 83 25 22];
            app.Spinner_16Label.Text = '';

            % Create estol_ar
            app.estol_ar = uispinner(app.MissionandRouteParametersPanel);
            app.estol_ar.Step = 0.5;
            app.estol_ar.Limits = [3 20];
            app.estol_ar.Tag = 'estol_ar';
            app.estol_ar.Position = [125 172 112 19];
            app.estol_ar.Value = 12;

            % Create run_btn
            app.run_btn = uibutton(app.MissionandRouteParametersPanel, 'push');
            app.run_btn.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushedFcn, true);
            app.run_btn.BackgroundColor = [0.2 0.6 0.302];
            app.run_btn.FontSize = 14;
            app.run_btn.FontWeight = 'bold';
            app.run_btn.Position = [9 43 233 43];
            app.run_btn.Text = 'Run Analysis';

            % Create status_lbl
            app.status_lbl = uilabel(app.MissionandRouteParametersPanel);
            app.status_lbl.Tag = 'status_lbl';
            app.status_lbl.HorizontalAlignment = 'center';
            app.status_lbl.FontSize = 10;
            app.status_lbl.FontColor = [0.6 0.6 0.6];
            app.status_lbl.Position = [9 17 233 19];
            app.status_lbl.Text = 'Ready';

            % Create AnalysisResultsPanel
            app.AnalysisResultsPanel = uipanel(app.UIFigure);
            app.AnalysisResultsPanel.TitlePosition = 'centertop';
            app.AnalysisResultsPanel.Title = 'Analysis Results';
            app.AnalysisResultsPanel.FontWeight = 'bold';
            app.AnalysisResultsPanel.Position = [268 9 657 723];

            % Create axes_power
            app.axes_power = uiaxes(app.AnalysisResultsPanel);
            title(app.axes_power, 'Power vs. Time')
            xlabel(app.axes_power, 'X')
            ylabel(app.axes_power, 'Y')
            zlabel(app.axes_power, 'Z')
            app.axes_power.Tag = 'axes_power';
            app.axes_power.Position = [17 370 302 327];

            % Create axes_soc
            app.axes_soc = uiaxes(app.AnalysisResultsPanel);
            title(app.axes_soc, 'Battery SoC')
            xlabel(app.axes_soc, 'X')
            ylabel(app.axes_soc, 'Y')
            zlabel(app.axes_soc, 'Z')
            app.axes_soc.Tag = 'axes_soc';
            app.axes_soc.Position = [337 370 302 327];

            % Create axes_scores
            app.axes_scores = uiaxes(app.AnalysisResultsPanel);
            title(app.axes_scores, 'Category Scores')
            ylabel(app.axes_scores, 'Y')
            zlabel(app.axes_scores, 'Z')
            app.axes_scores.Tag = 'axes_scores';
            app.axes_scores.Position = [17 17 302 327];

            % Create axes_range
            app.axes_range = uiaxes(app.AnalysisResultsPanel);
            title(app.axes_range, 'Energy vs. Distance')
            xlabel(app.axes_range, 'X')
            ylabel(app.axes_range, 'Y')
            zlabel(app.axes_range, 'Z')
            app.axes_range.Tag = 'axes_range';
            app.axes_range.Position = [337 17 302 327];

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.UIFigure);
            app.ResultsPanel.TitlePosition = 'centertop';
            app.ResultsPanel.Title = 'Results';
            app.ResultsPanel.FontWeight = 'bold';
            app.ResultsPanel.Position = [933 9 268 723];

            % Create eVTOLScoreLabel
            app.eVTOLScoreLabel = uilabel(app.ResultsPanel);
            app.eVTOLScoreLabel.HorizontalAlignment = 'center';
            app.eVTOLScoreLabel.FontWeight = 'bold';
            app.eVTOLScoreLabel.Position = [9 355 112 17];
            app.eVTOLScoreLabel.Text = 'eVTOL Score';

            % Create evtol_score_lbl
            app.evtol_score_lbl = uilabel(app.ResultsPanel);
            app.evtol_score_lbl.Tag = 'evtol_score_lbl';
            app.evtol_score_lbl.HorizontalAlignment = 'center';
            app.evtol_score_lbl.FontSize = 19;
            app.evtol_score_lbl.FontWeight = 'bold';
            app.evtol_score_lbl.FontColor = [0.2 0.502 0.8];
            app.evtol_score_lbl.Position = [9 325 112 34];
            app.evtol_score_lbl.Text = '-';

            % Create eSTOLScoreLabel
            app.eSTOLScoreLabel = uilabel(app.ResultsPanel);
            app.eSTOLScoreLabel.HorizontalAlignment = 'center';
            app.eSTOLScoreLabel.FontWeight = 'bold';
            app.eSTOLScoreLabel.Position = [134 355 112 17];
            app.eSTOLScoreLabel.Text = 'eSTOL Score';

            % Create estol_score_lbl
            app.estol_score_lbl = uilabel(app.ResultsPanel);
            app.estol_score_lbl.Tag = 'estol_score_lbl';
            app.estol_score_lbl.HorizontalAlignment = 'center';
            app.estol_score_lbl.FontSize = 19;
            app.estol_score_lbl.FontWeight = 'bold';
            app.estol_score_lbl.FontColor = [0.8 0.302 0.2];
            app.estol_score_lbl.Position = [134 325 112 34];
            app.estol_score_lbl.Text = '-';

            % Create winner_lbl
            app.winner_lbl = uilabel(app.ResultsPanel);
            app.winner_lbl.Tag = 'winner_lbl';
            app.winner_lbl.HorizontalAlignment = 'center';
            app.winner_lbl.FontSize = 16;
            app.winner_lbl.FontWeight = 'bold';
            app.winner_lbl.Position = [9 290 242 34];
            app.winner_lbl.Text = '-';

            % Create Label_16
            app.Label_16 = uilabel(app.ResultsPanel);
            app.Label_16.HorizontalAlignment = 'right';
            app.Label_16.FontName = 'Courier New';
            app.Label_16.Position = [40 480 25 22];
            app.Label_16.Text = '';

            % Create metrics_table
            app.metrics_table = uitextarea(app.ResultsPanel);
            app.metrics_table.Tag = 'metrics_table';
            app.metrics_table.Editable = 'off';
            app.metrics_table.FontName = 'Courier New';
            app.metrics_table.Position = [14 398 242 284];

            % Create RecommendationLabel
            app.RecommendationLabel = uilabel(app.ResultsPanel);
            app.RecommendationLabel.HorizontalAlignment = 'center';
            app.RecommendationLabel.FontWeight = 'bold';
            app.RecommendationLabel.Position = [9 232 242 17];
            app.RecommendationLabel.Text = 'Recommendation';

            % Create Label_17
            app.Label_17 = uilabel(app.ResultsPanel);
            app.Label_17.HorizontalAlignment = 'right';
            app.Label_17.Position = [40 111 25 22];
            app.Label_17.Text = '';

            % Create rec_text
            app.rec_text = uitextarea(app.ResultsPanel);
            app.rec_text.Tag = 'rec_text';
            app.rec_text.Editable = 'off';
            app.rec_text.Position = [9 52 242 176];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = routecomparisontool_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end