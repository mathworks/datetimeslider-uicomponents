classdef Advanced_Example_App < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './Advanced_Example_App.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        ExamplewithDatetimeSliderandDatetimeRangeSliderUIFigure  matlab.ui.Figure
        DatetimeRangeSlider             DatetimeRangeSlider
        DatetimeSlider                  DatetimeSlider
        UIAxes                          matlab.ui.control.UIAxes
        ContextMenu                     matlab.ui.container.ContextMenu
        MMMddMenu                       matlab.ui.container.Menu
        MMMdduuuuMenu                   matlab.ui.container.Menu
    end

    
    properties (Access = public)
        Line
        ROI
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            DateRange = app.DatetimeSlider.Limits(1):app.DatetimeSlider.Limits(2);
            plot(app.UIAxes,DateRange,rand(size(DateRange)))
            hold(app.UIAxes,"on")

            app.Line = xline(app.UIAxes,app.DatetimeSlider.Value(1));
            app.ROI = xregion(app.UIAxes,app.DatetimeRangeSlider.Value(1),app.DatetimeRangeSlider.Value(2));
            app.ROI.ContextMenu = app.ContextMenu;
        end

        % Menu selected function: MMMddMenu
        function MMMddMenuSelected(app, event)
            app.DatetimeSlider.DateFormat = "MMM dd";
        end

        % Menu selected function: MMMdduuuuMenu
        function MMMdduuuuMenuSelected(app, event)
            app.DatetimeSlider.DateFormat = "MMM d, uuuu";
        end

        % Callback function: DatetimeRangeSlider, DatetimeRangeSlider, 
        % ...and 2 other components
        function DatetimeSliderValueChanged(app, event)
            if event.EventName == "LimitsChanged"
                app.UIAxes.XLim = event.Source.Limits;%[app.DatetimeSlider.Limits(1),app.DatetimeSlider.Limits(2)];
                if ~isequal(app.DatetimeRangeSlider.Limits,app.UIAxes.XLim)
                    app.DatetimeRangeSlider.Limits = app.UIAxes.XLim;
                end
                if ~isequal(app.DatetimeSlider.Limits,app.UIAxes.XLim)
                    app.DatetimeSlider.Limits = app.UIAxes.XLim;
                end
            end
            
            app.Line.Value = app.DatetimeSlider.Value(1);         
            app.ROI.Value = [app.DatetimeRangeSlider.Value(1),app.DatetimeRangeSlider.Value(2)]; 
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = Advanced_Example_App(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end