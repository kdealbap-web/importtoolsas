{* 
* @Module Name: Leo Elements
* @Website: leotheme.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright Leotheme
* @description: LeoElements is module help you can build content for your shop
*}
{if isset($formAtts.lib_has_error) && $formAtts.lib_has_error}
    {if isset($formAtts.lib_error) && $formAtts.lib_error}
        <div class="alert alert-warning leo-lib-error">{$formAtts.lib_error}</div>
    {/if}
{else}
	{if isset($formAtts.title) && $formAtts.title}
		<h4 class="title_block">{$formAtts.title|escape:'html':'UTF-8'}</h4>
	{/if}
	{if isset($formAtts.sub_title) && $formAtts.sub_title}
	    <div class="sub-title-widget">{$formAtts.sub_title nofilter}</div>
	{/if}
	{if isset($formAtts.description) && $formAtts.description}
		<p>{$formAtts.description nofilter}{* HTML form , no escape necessary *}</p>
	{/if}
    {if !empty($formAtts.slides)}
		<div class="slick-row">
			<div class="slick-blogs slick-slider slick-loading" id="{$formAtts.form_id|escape:'html':'UTF-8'}">
				{foreach from=$formAtts.slides item=slider name=mypLoop} 
					<div class="slick-slide {if $smarty.foreach.mypLoop.index == 0} first{/if}">
						<div class="item">
							<div class="block-carousel-container">
								<div class="left-block">
									<div class="block-carousel-image-container image">
										<div class="ap-more-info" data-id="{$slider._id|intval}"></div>
										{if $slider.item_link.url}
                                            <a title="{$slider.item_title}" href="{$slider.item_link.url}">
										{/if}
										<div class="item-title" style="width:100%">{$slider.item_title}</div>
										{if isset($slider.item_image) && !empty($slider.item_image) && isset($slider.item_image.url) && !empty($slider.item_image.url)}
										<div class="item-image">
											<img class="img-fluid" src="{$slider.item_image.url}" alt="{if isset($slider.item_title)}{$slider.item_title|escape:'html':'UTF-8'}{/if}"/>
										</div>
										{/if}

										{if isset($slider.item_sub_title) && !empty($slider.item_sub_title)}
											<p class="item-sub-title">{$slider.item_sub_title|escape:'html':'UTF-8' nofilter}</p>
										{/if}
										{if isset($slider.item_description) && !empty($slider.item_description)}
											<div class="item-description">{$slider.item_description|rtrim nofilter}{* HTML form , no escape necessary *}</div>
										{/if}
										{if $slider.item_link.url}{*full link can not escape*}
										</a>
										{/if}
									</div>
								</div>
							</div>
						</div>
					</div>
				{/foreach}
			</div>
		</div>


<script type="text/javascript" class="autojs" data-form_id="{$formAtts.form_id}">
    var {$formAtts.form_id} = (function(){
	$('#{$formAtts.form_id|escape:'html':'UTF-8'}').imagesLoaded( function() {
		$('#{$formAtts.form_id|escape:'html':'UTF-8'}').slick(
			{if $formAtts.slick_custom_status}
				{$formAtts.slick_custom}
			{else}
			{
				centerMode: {if isset($formAtts.slick_centermode) && $formAtts.slick_centermode}true{else}false{/if},
				centerPadding: '{if isset($formAtts.slick_centerpadding) && $formAtts.slick_centerpadding}{$formAtts.slick_centerpadding}{else}0{/if}px',
				dots: {if $formAtts.slick_dot}true{else}false{/if},
				infinite: {if isset($formAtts.infinite) && $formAtts.infinite}true{else}false{/if},
				vertical: {if $formAtts.slick_vertical}true{else}false{/if},
				verticalSwiping : {if $formAtts.slick_vertical}true{else}false{/if},
				autoplay: {if $formAtts.autoplay}true{else}false{/if},
				pauseonhover: {if $formAtts.pause_on_hover}true{else}false{/if},
				autoplaySpeed: {if isset($formAtts.autoplay_speed) && $formAtts.autoplay_speed}{$formAtts.autoplay_speed}{else}5000{/if},
                                speed: {if isset($formAtts.speed) && $formAtts.speed}{$formAtts.speed}{else}500{/if},
				arrows: {if $formAtts.slick_arrows}true{else}false{/if},
				rows: {$formAtts.per_col},
				slidesToShow: {$formAtts.slides_to_show},
				slidesToScroll: {if $formAtts.slick_dot}{$formAtts.slides_to_show}{else}{$formAtts.slides_to_show}{/if},
				rtl: {if isset($IS_RTL) && $IS_RTL}true{else}false{/if},
                                responsive: [{
                                    breakpoint: 1025,
                                    settings: {
                                        slidesToShow: {$formAtts.slides_to_show_tablet},
                                        slidesToScroll: {$formAtts.slides_to_scroll_tablet}
                                    }
                                }, {
                                    breakpoint: 768,
                                    settings: {
                                        slidesToShow: {$formAtts.slides_to_show_mobile},
                                        slidesToScroll: {$formAtts.slides_to_scroll_mobile}
                                    }
                                }]
			}
			{/if}
		);
		$('#{$formAtts.form_id|escape:'html':'UTF-8'}').removeClass('slick-loading').addClass('slick-loaded').parents('.slick-row').addClass('hide-loading');
	});

    });
</script>      
    {else}
        <p class="alert alert-info">{l s='No slide at this time.' mod='leoelements'}</p>
    {/if}
{/if}
