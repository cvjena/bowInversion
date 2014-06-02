function debug_disp( sText, settings)
    if settings.b_verbose
        fprintf('%s %s\n', datestr(now), sText);
    end
end