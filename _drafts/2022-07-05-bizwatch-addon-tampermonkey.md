---
---

```js
// ==UserScript==
// @name         FCO Bizwatch Addon
// @version      0.20190902
// @match        http://srvw9030/*
// @match        http://srvw9025/*
// @grant        GM_addStyle
// @require      https://cdn.jsdelivr.net/npm/select2@4.0.3/dist/js/select2.min.js
// @require      https://kit.fontawesome.com/44eb762289.js
// @require      https://cdn.jsdelivr.net/npm/lodash@4.17.11/core.min.js
// @require      https://cdn.jsdelivr.net/npm/store@2.0.12/dist/store.modern.min.js
// ==/UserScript==

function FcoBizwatchAddon() {
    // intro
    'use strict';
    console.log('== FCO Bizwatch Addon ==');

    // class constants
    const OBJECTS = {
        ALL:-1,
        PRODUCT: 1,
        PRICING: 4,
        CONSUMER: 6,
        SALESORDER: 9,
        INVENTORY: 10,
        HIERARCHY: 11,
        CUSTOMER: 17,
        LOYALTY: 24,
    };
    const DROPDOWNS = [
        '#refContextDropDown',
        '#refBusinessObjectDropDown',
        '#sourceDropDown',
        '#targetDropDown',
        '#refFunctionalExchangeDropDown',
    ];
    const STATUS = {
        ALL: -1,
        IN_PROGRESS: 1,
        OK: 2,
        WARNING: 3,
        PARTIAL: 4,
        ERROR: 5,
        RESUBMITTED: 6,
    };
    const STORE_KEY = 'FCO Bizwatch Addon';
    // statuses as jQuery objects
    const $STATUS = {
        ALL: $('input:checkbox[value="'+STATUS.ALL+'"]'),
        IN_PROGRESS: $('input:checkbox[value="'+STATUS.IN_PROGRESS+'"]'),
        OK: $('input:checkbox[value="'+STATUS.OK+'"]'),
        WARNING: $('input:checkbox[value="'+STATUS.WARNING+'"]'),
        PARTIAL: $('input:checkbox[value="'+STATUS.PARTIAL+'"]'),
        ERROR: $('input:checkbox[value="'+STATUS.ERROR+'"]'),
        RESUBMITTED: $('input:checkbox[value="'+STATUS.RESUBMITTED+'"]'),
    }

    // define environment
    const ENVS = {
        PROD: {fileshare: 'ProdMed', name: 'PROD', host: 'srvw9030', Mediation_Files_Share_Name: 'PROD', Mediation_Files_Share_WebService: '\\\\ProdMed\\Mediation_Files_Share\\WebService\\Consumer\\PROD\\Archive\\In\\%SOURCE%\\'},
        PREPROD: {fileshare: 'PreprodMed', name: 'Preprod', host: 'srvw9025', Mediation_Files_Share_Name: 'PREPROD', Mediation_Files_Share_WebService:'\\\\PreprodMed\\Mediation_Files_Share\\WebServices\\Consumer\\PREPROD\\Archive\\%SOURCE%\\'},
    };
    const ENV = _(ENVS).find(function(o){ return o.host == document.location.host; });
    // add header
    if(ENV == ENVS.PROD){
        $('header').prepend('<section class="bg-danger row text-white text-center"><div class="col-4">FCO Bizwatch Addon</div><div class="col-4">'+ENV.name+'</div><div class="col-4 text-right"><a href="http://'+ENVS.PREPROD.host+'/MonitoringPortal" target="_blank">Switch to '+ENVS.PREPROD.name+' <i class="fas fa-external-link-alt"></i></a></div></section>');
    } else {
        $('header').prepend('<section class="bg-info row text-white text-center"><div class="col-4">FCO Bizwatch Addon</div><div class="col-4">'+ENV.name+'</div><div class="col-4 text-right"><a href="http://'+ENVS.PROD.host+'/MonitoringPortal" target="_blank">Switch to '+ENVS.PROD.name+' <i class="fas fa-external-link-alt"></i></a></div></section>');
    }

    console.log(store);

    // CSS libs
    $('head').append('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/css/bootstrap.min.css">');
    $("head").append('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2@4.0.3/dist/css/select2.min.css"/>');

    // Load prefs
    initPrefs();

    // router based on document.location.pathname
    var pathname = document.location.pathname;
    if(pathname.match(/^\/MonitoringPortal\/audit\/exchangeDetails/)){
        console.log('FCO Page: Audit Details');
        pageAuditDetails();
    } else if(pathname.match(/^\/MonitoringPortal/)){
        console.log('FCO Page: Audit');
        pageAudit();
    } else {
        console.log('FCO Page: No matching page found');
    }

    function pageAudit(){
        // CSS perso
        GM_addStyle('.custom-combobox { display: none !important; } #identifiers-items .custom-combobox { display: block !important; }');
        //GM_addStyle('#refContextDropDown, #refBusinessObjectDropDown, #sourceDropDown, #targetDropDown { width: 50%; }');
        GM_addStyle('#refFunctionalExchangeDropDown { width: 100%; }');
        GM_addStyle('.select2-container { font-size: .85em; }');
        GM_addStyle('.select2-results__option { font-size: .85em; }');
        GM_addStyle('.btn > * { cursor: pointer; ');
        GM_addStyle('#refContextDropDown, #refBusinessObjectDropDown, #sourceDropDown, #targetDropDown {width: 100%;}')

        //$('#ui-accordion-accordion-panel-0').prepend('<div id="fco" class="row"><div id="domain" class="col-3"></div><div id="object" class="col-3"></div><div id="source" class="col-3"></div><div id="target" class="col-3"></div>');

        // load prefs
        var prefs = getPrefs();
        for(var dropdown of DROPDOWNS){
            console.log('- importing', prefs[dropdown], 'to', dropdown);
            $(dropdown).val(prefs[dropdown]);
        }
        for(var key in $STATUS){
            // unselect
            $STATUS[key].prop('checked', false);
            // select if in prefs
            if(prefs.status && prefs.status.indexOf(key) > -1){
                $STATUS[key].prop('checked', true);
            }
        };


        // Dropdowns select2
        $('#refContextDropDown').show();
        $('#refContextDropDown').appendTo('#domain');
        $('#refContextDropDown').select2();
        $('#refContextDropDown').change(function(){ onFlowChange(); });
        $('#refBusinessObjectDropDown').show();
        $('#refBusinessObjectDropDown').appendTo('#object');
        $('#refBusinessObjectDropDown').select2();
        $('#refBusinessObjectDropDown').change(function(){ onFlowChange(); });
        $('#sourceDropDown').show();
        $('#sourceDropDown').appendTo('#source');
        $('#sourceDropDown').select2();
        $('#sourceDropDown').change(function(){ onFlowChange(); });
        $('#targetDropDown').show();
        $('#targetDropDown').appendTo('#target');
        $('#targetDropDown').select2();
        $('#targetDropDown').change(function(){ onFlowChange(); });
        //
        $('#refFunctionalExchangeDropDown').show();
        $('#refFunctionalExchangeDropDown').select2();
        $('#refFunctionalExchangeDropDown').change(function(){ refFunctionalExchangeDropDownSelectedChange($(this)) });
        //$('#refFunctionalExchangeDropDown').attr('size', 10);

        // wrap checkboxes in buttons
        $('.clsDivComponent:nth-of-type(6) > .clsComponent > label[style="display: inline; font-weight: 100;"]').remove();
        $STATUS.ERROR.add($STATUS.ERROR.next()).wrapAll('<div class="btn btn-danger"></div>');
        $STATUS.OK.add($STATUS.OK.next()).wrapAll('<div class="btn btn-success"></div>');
        $STATUS.IN_PROGRESS.add($STATUS.IN_PROGRESS.next()).wrapAll('<div class="btn btn-info"></div>');
        $STATUS.PARTIAL.add($STATUS.PARTIAL.next()).wrapAll('<div class="btn btn-info"></div>');
        $STATUS.RESUBMITTED.add($STATUS.RESUBMITTED.next()).wrapAll('<div class="btn btn-info"></div>');
        $STATUS.WARNING.add($STATUS.WARNING.next()).wrapAll('<div class="btn btn-warning"></div>');
        $STATUS.ALL.add($STATUS.ALL.next()).wrapAll('<div class="btn btn-info"></div>');
        // make the whole button clickable
        for(var key in $STATUS){
            $STATUS[key].parent().click(function(e){
                // save to prefs
                var prefs = getPrefs();
                prefs.status = [];
                for(var key in $STATUS){
                    if(!$STATUS[key].prop('checked')){
                        continue;
                    }
                    console.log('- $STATUS '+key+':', $STATUS[key])
                    prefs.status.push(key);
                }
                setPrefs(prefs);
                // bugfix: if the checkbox is clicked, no need to continue
                if(e.target.tagName == 'INPUT'){
                    return;
                };
                // check the checkbox
                $(this).find('input').trigger('click');
            });
        }

        // add the helpers div
        $('<div id="helpers" class="mb-4"/>').insertBefore('#identifiers-items');
        $('#helpers').append('<div>Cc-UCR-X IN MEDIATION: '+ENV.Mediation_Files_Share_WebService.replace('%SOURCE%', 'UCR'));
        $('#helpers').append('<div>Cc-X-UCR OUT MEDIATION: \\\\'+ENV.fileshare+'\\Mediation_Files_Share\\Ucr\\'+ENV.Mediation_Files_Share_Name+'\\Consumer\\Archive\\Out');
        $('#helpers').append('<div>MediationThèque Consumer <a target="_blank" href="https://wwpcis.sharepoint.com/:f:/r/sites/PCIStheque/mediation/InterfaceSpecifications/Consumer">wwpcis.sharepoint.com/../mediation/InterfaceSpecifications/Consumer</a></div>');

        // search
        /// unbind all click events
        $('#searchButton').off('click');
        /// custom on click function
        $('#searchButton').click(function(e, data){
            /**
             * Taken from Bizwatch
             */
            $("#btnExport").hide();

            //Remove the table
            $("#gridsearch").remove();
            $('#gridsearch').html('');
            $('#gridsearch').empty();
            $("#gridsearch tr").html('');
            $("#gridsearch > tr").html('');
            $('#gridsearch tr').empty();
            $('#gridsearch > tr').empty();
            $('.gridsearch tr').remove();
            $('#gridsearch > tr').remove();
            $("#pager").hide();

            GetPacketResultsFCO(data == null ? null : data.rowCount);

            $('.centeredColumn > a').addClass('btn btn-sm btn-secondary');
        });

        // reset button
        $('#resetButton').click(function(){
            $(DROPDOWNS).each(function(){
                $(this).select2();
            });
        });
    }

    function onFlowChange(){
        console.log('onFlowChange');
        // save pref
        var prefs = getPrefs();
        for(var dropdown of DROPDOWNS){
            console.log('- saving:', dropdown)
            prefs[dropdown] = $(dropdown).val();
        }
        setPrefs(prefs);

        // refresh flows
        refreshComboboxRefFunctionalExchanges();

        $('#refFunctionalExchangeDropDown').show();
    }

    function initPrefs(){
        var prefs = getPrefs();
        if(!prefs){
            console.log('Prefs created for the first time');
            prefs = {};
            setPrefs(prefs);
        }
        console.log('Prefs loaded:', JSON.stringify(prefs));
    }
    function getPrefs(){
        return store.get(STORE_KEY);
    }
    function setPrefs(prefs){
        return store.set(STORE_KEY, prefs);
    }

    /**
     * Taken from Bizwatch
     */
    function GetPacketResultsFCO(rowCount) {
        if (!$('#refFunctionalExchangeDropDown').val()){
            $("#dialog-message").dialog("open");
        } else {
            $("#loading").fadeIn();

            $.ajax({
                type: 'GET',
                url: '/MonitoringPortal/audit/exchangeListViewHtml',
                contentType: "application/html; charset=utf-8",
                dataType: "html",
                traditional: true,
                cache: false,
                data: {
                    refContextId: $('#refContextDropDown').val(),
                    refBusinessObjectId: $('#refBusinessObjectDropDown').val(),
                    sourceId: $('#sourceDropDown').val(),
                    targetId: $('#targetDropDown').val(),
                    refFunctionalExchangeId: $('#refFunctionalExchangeDropDown').val(),
                    startDate: startDateTextBox.val(),
                    endDate: endDateTextBox.val(),
                    identifiers: getIdentifierValues(),
                    statut: getStatusValues().join(','),
                    page: 1,
                    rowCount: rowCount
                },

                success: function (result) {
                    $("#searchResultContainer").html(result);
                    $("#loading").fadeOut();
                },

                error: function (result) {
                    var _div = $("<div class='jtable-main-container'><div class='jtable-title'><div class='jtable-title-text'>Search results</div></div><div class='jtable-title-text'>There are errors when loading search results, please contact your administrator. (" + result.status + ") " + result.statusText + ".</div></div>");
                    $('#searchResultContainer').html(_div);

                    $("#loading").fadeOut();
                }
            });
        }
    }

    function pageAuditDetails(){

    }
};

const fcoBizwatchAddon = FcoBizwatchAddon();

/**
TODO


CHANGELOG
20190902 Les status sont sauvegardés dans les prefs + fix affichage des filtres "identifiers" + fix Reset Filters
20190830 Les valeurs des 5 dropdowns sont sauvegardés dans les prefs avec storeJS
20910825 Fix des URL Cc-UCR-In et Cc-UCR-Out qui étaient incorrectes pour la prod
20910820 Ajout des URL Cc-UCR-In, Cc-UCR-Out, Médiationthèque
20190814 Gestion d'un autre environemennt: préprod
*/

```
