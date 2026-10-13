classdef DatetimeSlider_Example_App < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './DatetimeSlider_Example_App.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        ExamplewithDatetimeSliderUIFigure  matlab.ui.Figure
        DatetimeSlider                  DatetimeSlider
        UIAxes                          matlab.ui.control.UIAxes
        ContextMenu                     matlab.ui.container.ContextMenu
        MMMddMenu                       matlab.ui.container.Menu
        MMMdduuuuMenu                   matlab.ui.container.Menu
    end

    
    properties (Access = public)
        Line
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            DateRange = app.DatetimeSlider.Limits(1):app.DatetimeSlider.Limits(2);
            plot(app.UIAxes,DateRange,rand(size(DateRange)))
            hold(app.UIAxes,"on")

            app.Line = xline(app.UIAxes,app.DatetimeSlider.Value(1));
        end

        % Menu selected function: MMMddMenu
        function MMMddMenuSelected(app, event)
            app.DatetimeSlider.DateFormat = "MMM dd";
        end

        % Menu selected function: MMMdduuuuMenu
        function MMMdduuuuMenuSelected(app, event)
            app.DatetimeSlider.DateFormat = "MMM d, uuuu";
        end

        % Callback function: DatetimeSlider, DatetimeSlider
        function DatetimeSliderValueChanged(app, event)
            app.UIAxes.XLim = [app.DatetimeSlider.Limits(1),app.DatetimeSlider.Limits(2)];
            app.Line.Value = app.DatetimeSlider.Value(1);
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = DatetimeSlider_Example_App(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end