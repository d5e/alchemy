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


function localeToFloat(string) {
    if (typeof string == 'number')
        return string;
    if ( 'de' == $('html').attr('lang'))
        string = string.replace(/\./g,'').replace(/,/g,'.');
    else
        string = string.replace(/\,/g,'')
    return parseFloat(string);
}


    
window.runAfterInit = function(){
    
    $('[data-toggle="tooltip"]:visible').tooltip(
        { delay: 180}
    );
    
    console.log("ready");
    
    
    $('form').on('change', 'select.form-control.substance.having-dilution-select', function(e) {
        
        console.log("doing");
        
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
        console.log("done");
    });

    $('form').on('change', '.dilution-wizard select.dilution.wizard', function(e) {
        var sd = $(this);
        var parent = sd.closest('.form-group.dilution-wizard');
        var amount = parent.find('input[data-concentration]');
        var old_concentration = localeToFloat(amount.attr('data-concentration'));
        var new_concentration = localeToFloat(sd.find('option:selected').attr('data-concentration'));
        var scale = old_concentration / new_concentration;
        amount.val(localeToFloat(amount.val()) * scale);
        amount.attr('data-concentration', new_concentration);
    });

    $('form').on('click', '.btn-group a[data-color-selector="list"]', function(e) {
        var cs = $(this);
        var parent = cs.closest('.btn-group');
        var hidden = parent.find('input[type="hidden"]');
        var button = parent.find('button[data-color-selector="list"]')
        var name = cs.attr('data-name');
        button.find('span.name').text(name.toUpperCase());
        hidden.val(name);
        var oldc = button.attr('class');
        if (!oldc)            return;
        var nc = oldc.replace(/color\-\w+/,'')
        console.log(nc);
        button.attr('class',  nc);
        button.addClass('color-' + name);
    });
    
    

};

jQuery(document).ready(window.runAfterInit);

$(document).on("page:load", window.runAfterInit);




/***************************    IE    ***************************/

/* do nothing on call console if console not exists */
if (!window.console)
    window.console = {
        log : function(str) {},
        debug : function(str) {},
        warn : function(str) { alert("console.warn: " + str); }
    };
