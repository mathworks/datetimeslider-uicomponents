classdef DatetimeSlider < matlab.ui.componentcontainer.ComponentContainer

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout      matlab.ui.container.GridLayout
        CurrentDate     matlab.ui.control.DatePicker
        EndDateLabel    matlab.ui.control.Label
        EndDate         matlab.ui.control.DatePicker
        EndDateLabel_2  matlab.ui.control.Label
        StartDate       matlab.ui.control.DatePicker
        StartDateLabel  matlab.ui.control.Label
        Slider          matlab.ui.control.Slider
    end

    % Events with associated public callbacks
    events (HasCallbackProperty, NotifyAccess = private)
        DateFormatChanged
        LimitsChanged
        ValueChanged
    end

    
    properties
        Value datetime = datetime('today'); % Current selected date
        Limits datetime = [datetime('today'),datetime('today') + calmonths(1)];% Allowable date range
        DateFormat char = 'dd-MMM-yyyy'% Format for displaying dates
    end
    
    methods

        % Set methods for Value and Limits
        function set.Value(comp, value)
            comp.Value = datetime(value,'Format',comp.DateFormat);
            % Update UI components accordingly
            LimitsorValueChanged(comp);
            notify(comp, 'ValueChanged');
        end

        function set.Limits(comp, limits)
            comp.Limits = limits;
            % Update UI components accordingly
            LimitsorValueChanged(comp);
            notify(comp, 'LimitsChanged');
        end

        function set.DateFormat(comp, format)
            comp.DateFormat = format;
            % Update date pickers and tick labels
            UpdateDateFormat(comp);
            notify(comp, 'DateFormatChanged');
        end

        function UpdateSliderValue(comp,event)
             % Check if StartDate is before EndDate
            if comp.StartDate.Value < comp.EndDate.Value
                % Update the slider and other components
                postSetupFcn(comp)
            else
                % Alert the user if StartDate is not before EndDate
                try
                    uialert(ancestor(comp,"Figure"),"Start date must be before End Date","Incorrect Date Range")
                catch ME
                    rethrow(ME);
                end
                % Revert to the previous value if the condition is not met
                event.Source.Value = event.PreviousValue;
            end
        end

        function UpdateCurrentDate(comp,event)
            try
                % Calculate the new slider value based on the selected date
                newCurrentDateValue = datenum(comp.CurrentDate.Value) - datenum(comp.StartDate.Value) + 1;

                % Check if the newMinValue is within the valid range
                if newCurrentDateValue >= 1 && newCurrentDateValue <= diff(comp.Slider.Limits) + 1
                    comp.Slider.Value(1) = newCurrentDateValue;
                else
                    error('Date out of range');
                end

            catch
                % Alert the user if the selected date is outside the allowable range
                uialert(ancestor(comp,"Figure"), "Date must be within limits", "Outside of Date Range");

                % Revert to the previous value if the condition is not met
                try
                    comp.CurrentDate.Value = event.PreviousValue;
                catch
                    comp.CurrentDate.Value = comp.StartDate.Value;
                end
            end
        end
        
    end
    
    methods (Access = private)
        
        function LimitsorValueChanged(comp)
            % Use this function to update the underlying components

            % Limits changed
            [comp.StartDate.Value, comp.EndDate.Value] = deal(comp.Limits(1),comp.Limits(2));
            UpdateSliderValue(comp)

            % % Selected Values changed
            comp.CurrentDate.Value = comp.Value(1);
            UpdateCurrentDate(comp)
        end
        
        function UpdateDateFormat(comp)
            increment = days(round(days(comp.EndDate.Value-comp.StartDate.Value)/10));
            DatetimeRange = comp.StartDate.Value:increment:comp.EndDate.Value;
            comp.Slider.MajorTickLabels = categorical(datetime(DatetimeRange,"Format",comp.DateFormat));
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function postSetupFcn(comp)
            % initialize properties
            if isnat(comp.CurrentDate.Value)
                comp.EndDate.Value = datetime('today') + calmonths(1);
                comp.StartDate.Value = datetime('today');
                comp.CurrentDate.Value = datetime('today');         
            end
            
            increment = days(round(days(comp.EndDate.Value-comp.StartDate.Value)/10));
            DatetimeRange = comp.StartDate.Value:increment:comp.EndDate.Value;
            comp.Slider.MajorTicks = 1:datenum(increment):length(DatetimeRange)*datenum(increment);
            comp.Slider.MajorTickLabels = categorical(datetime(DatetimeRange,"Format",comp.DateFormat));
            comp.Slider.Limits = [1 length(DatetimeRange)*datenum(increment)-1];

            try
                comp.Slider.Value = datenum(comp.CurrentDate.Value)-datenum(comp.StartDate.Value)+1;
            catch
                comp.Slider.Value = comp.Slider.Limits(1);
            end

        end

        % Value changed function: CurrentDate
        function CurrentDateValueChanged(comp, event)
            try
                comp.Slider.Value = datenum(comp.CurrentDate.Value)-datenum(comp.StartDate.Value)+1;
            catch
                uialert(ancestor(comp,"Figure"), "Date must be within limits", "Outside of Date Range");
                
                % Revert to the previous value if the condition is not met
                try
                    comp.CurrentDate.Value = event.PreviousValue;
                catch
                    comp.CurrentDate.Value = comp.StartDate.Value;
                end
            end
        end

        % Value changed function: Slider
        function SliderValueChanged(comp, event)
             % Generate the range of available dates between StartDate and EndDate
            DatetimeRange = comp.StartDate.Value:comp.EndDate.Value;

            % Ensure slider values are integers
            comp.Slider.Value = floor(comp.Slider.Value);

            % Update the selected minimum and maximum dates
            try
                comp.CurrentDate.Value = DatetimeRange(comp.Slider.Value(1));
                comp.Value = comp.CurrentDate.Value;
            catch
                % Handle cases where slider values might be out of bounds
                warning('Slider values are out of bounds. Please check the date range.');
                return;
            end
            
            
            % UpdateCurrentDate(comp,event)
            % comp.Value(1) = comp.CurrentDate.Value;
            % comp.CurrentDate.Value = datetime((comp.Slider.Value + datenum(comp.StartDate.Value) - 1),'ConvertFrom','datenum');
        end

        % Value changed function: EndDate, StartDate
        function StartDateValueChanged(comp, event)
            UpdateSliderValue(comp,event)
            comp.Limits =[comp.StartDate.Value, comp.EndDate.Value];
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components
            
        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 900 116];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = {'0.1x', 'fit', '1x', 'fit', '1x', 'fit', '0.1x'};
            comp.GridLayout.RowHeight = {10, 22, 22, 18};
            comp.GridLayout.ColumnSpacing = 13.5416666666667;
            comp.GridLayout.RowSpacing = 8;
            comp.GridLayout.Padding = [13.5416666666667 8 13.5416666666667 8];

            % Create Slider
            comp.Slider = uislider(comp.GridLayout);
            comp.Slider.MajorTicks = [0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100];
            comp.Slider.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @SliderValueChanged, true);
            comp.Slider.Layout.Row = [3 4];
            comp.Slider.Layout.Column = [3 5];

            % Create StartDateLabel
            comp.StartDateLabel = uilabel(comp.GridLayout);
            comp.StartDateLabel.FontWeight = 'bold';
            comp.StartDateLabel.Layout.Row = 2;
            comp.StartDateLabel.Layout.Column = 2;
            comp.StartDateLabel.Text = 'Limit Start Date:';

            % Create StartDate
            comp.StartDate = uidatepicker(comp.GridLayout);
            comp.StartDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @StartDateValueChanged, true);
            comp.StartDate.FontWeight = 'bold';
            comp.StartDate.Layout.Row = 3;
            comp.StartDate.Layout.Column = 2;

            % Create EndDateLabel_2
            comp.EndDateLabel_2 = uilabel(comp.GridLayout);
            comp.EndDateLabel_2.FontWeight = 'bold';
            comp.EndDateLabel_2.Layout.Row = 2;
            comp.EndDateLabel_2.Layout.Column = 6;
            comp.EndDateLabel_2.Text = 'Limit End Date:';

            % Create EndDate
            comp.EndDate = uidatepicker(comp.GridLayout);
            comp.EndDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @StartDateValueChanged, true);
            comp.EndDate.FontWeight = 'bold';
            comp.EndDate.Layout.Row = 3;
            comp.EndDate.Layout.Column = 6;

            % Create EndDateLabel
            comp.EndDateLabel = uilabel(comp.GridLayout);
            comp.EndDateLabel.HorizontalAlignment = 'right';
            comp.EndDateLabel.FontWeight = 'bold';
            comp.EndDateLabel.Layout.Row = 2;
            comp.EndDateLabel.Layout.Column = 3;
            comp.EndDateLabel.Text = 'Current Date:';

            % Create CurrentDate
            comp.CurrentDate = uidatepicker(comp.GridLayout);
            comp.CurrentDate.ValueChangedFcn = matlab.apps.createCallbackFcn(comp, @CurrentDateValueChanged, true);
            comp.CurrentDate.Layout.Row = 2;
            comp.CurrentDate.Layout.Column = 4;
            
            % Execute the startup function
            postSetupFcn(comp)
        end
    end
end