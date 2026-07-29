/*
 *  @Website: apollotheme.com - prestashop template provider
 *  @author Apollotheme <apollotheme@gmail.com>
 *  @copyright Apollotheme
 *  @description: ApPageBuilder is module help you can build content for your shop
 */
// JavaScript Document
$(document).ready( function(){
	$(".bgpattern").each( function(){
		var wrap = this;
		if( $("input",wrap).val() ){	
			$("#" + $("input",wrap).val()).addClass("active"); 
		}
		$("a",this).click( function(){
		 	  $("input",wrap).val( $(this).attr("id").replace(/\.\w+$/,"") );
			  $("a",wrap).removeClass( "active" );
			  $(this).addClass("active");
		} );
	} );
} );