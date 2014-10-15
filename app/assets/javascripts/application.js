// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require bootstrap-sprockets

//= require jquery_nested_form


jQuery(document).ready(function($){
    
    
    
    
    $('[data-toggle="tooltip"]:visible').tooltip(
        { delay: 180}
    );
    
    
    
    
    
    
    $('select.form-control.substance.having-dilution-select').on('change', function (e) {
        var element = $(this);
        var substanceID = element.val();
        if (!(substanceID > 0))
            return;
        var parent = element.closest('.form-group');
        var dilutionSelect = parent.find('select.form-control.dilution.need-filtering');
        var dilutionSelectedVal = dilutionSelect.val();
        var firstDilution = dilutionSelect.find('option:not(:disabled):first');
        var optionsEnable = dilutionSelect.find('option[data-substance-id="' + substanceID + '"]');
        var optionsDisable = dilutionSelect.find('option:not([data-substance-id="' + substanceID + '"])');
        optionsEnable.each( function(i,e) {
            $(e).attr('disabled', null);
        });
        var activeGotDisabled = false;
        optionsDisable.each( function(i,e) {
            var el = $(e);
            if (el.val()) {
                el.attr('disabled', '');
                if (dilutionSelectedVal == el.val())
                    activeGotDisabled = true;
            }
        });
        if (activeGotDisabled)
            dilutionSelect.val(firstDilution.val());
    });
    
    
    
    
    
    

}); // end of jQuery(document).ready



