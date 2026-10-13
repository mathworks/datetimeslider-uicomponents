classdef DatetimeRangeSlider_Example_App < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './DatetimeRangeSlider_Example_App.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        ExamplewithDatetimeRangeSliderUIFigure  matlab.ui.Figure
        DatetimeRangeSlider             DatetimeRangeSlider
        UIAxes                          matlab.ui.control.UIAxes
        ContextMenu                     matlab.ui.container.ContextMenu
        MMMddMenu                       matlab.ui.container.Menu
        MMMdduuuuMenu                   matlab.ui.container.Menu
    end

    
    properties (Access = public)
        ROI
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            DateRange = app.DatetimeRangeSlider.Limits(1):app.DatetimeRangeSlider.Limits(2);
            plot(app.UIAxes,DateRange,rand(size(DateRange)))
            hold(app.UIAxes,"on")

            app.ROI = xregion(app.UIAxes,app.DatetimeRangeSlider.Value(1),app.DatetimeRangeSlider.Value(2));

            % app.UIAxes.ContextMenu =
            app.ROI.ContextMenu = app.ContextMenu;%uicontextmenu(app.ExamplewithDatetimeRangeSliderUIFigure);
            % uimenu(app.ROI.ContextMenu, 'Text','something');
        end

        % Menu selected function: MMMddMenu
        function MMMddMenuSelected(app, event)
            app.DatetimeRangeSlider.DateFormat = "MMM dd";
        end

        % Menu selected function: MMMdduuuuMenu
        function MMMdduuuuMenuSelected(app, event)
            app.DatetimeRangeSlider.DateFormat = "MMM d, uuuu";
        end

        % Callback function: DatetimeRangeSlider, DatetimeRangeSlider
        function DatetimeRangeSliderValueChanged(app, event)
            app.UIAxes.XLim = [app.DatetimeRangeSlider.Limits(1),app.DatetimeRangeSlider.Limits(2)];
            app.ROI.Value = [app.DatetimeRangeSlider.Value(1),app.DatetimeRangeSlider.Value(2)];  
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = DatetimeRangeSlider_Example_App(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end