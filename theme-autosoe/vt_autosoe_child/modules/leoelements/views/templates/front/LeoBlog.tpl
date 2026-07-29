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

    <div id="blog-{$formAtts.form_id|escape:'html':'UTF-8'}" data-runjs="1" data-form_id="{$formAtts.form_id}" class="autojs block latest-blogs exclusive elementor-slick-slider {(isset($formAtts.class)) ? $formAtts.class : ''|escape:'html':'UTF-8'}">
        {if isset($formAtts.show_title) && $formAtts.show_title && isset($formAtts.title)&&!empty($formAtts.title)}
        <h4 class="title_block">
            {$formAtts.title|rtrim|escape:'html':'UTF-8'}
        </h4>
        {/if}
        {if isset($formAtts.show_sub_title) && $formAtts.show_sub_title && isset($formAtts.sub_title) && $formAtts.sub_title}
            <div class="sub-title-widget">{$formAtts.sub_title nofilter}</div>
        {/if}
        <div class="block_content">
            {if !empty($products)}
                {if $formAtts.view_type == "slickcarousel"}
{if isset($formAtts.lib_has_error) && $formAtts.lib_has_error}
    {if isset($formAtts.lib_error) && $formAtts.lib_error}
        <div class="alert alert-warning leo-lib-error">{$formAtts.lib_error}</div>
    {/if}
{else}
	{if !empty($products)}
		<div class="slick-row">
			<div class="timeline-wrapper clearfix prepare"
				data-item="{$formAtts.number_fake_item}" 
				data-xl="{if isset($formAtts.array_fake_item.xl)}{$formAtts.array_fake_item.xl}{/if}" 
				data-lg="{if isset($formAtts.array_fake_item.lg)}{$formAtts.array_fake_item.lg}{/if}" 
				data-md="{if isset($formAtts.array_fake_item.md)}{$formAtts.array_fake_item.md}{/if}" 
				data-sm="{if isset($formAtts.array_fake_item.sm)}{$formAtts.array_fake_item.sm}{/if}" 
				data-m="{if isset($formAtts.array_fake_item.m)}{$formAtts.array_fake_item.m}{/if}"
			>
				{for $foo=1 to $formAtts.number_fake_item}			
					<div class="timeline-parent">
						{for $foo_child=1 to $formAtts.per_col}
							<div class="timeline-item">
								<div class="animated-background">					
									<div class="background-masker content-top"></div>							
									<div class="background-masker content-second-line"></div>							
									<div class="background-masker content-third-line"></div>							
									<div class="background-masker content-fourth-line"></div>
								</div>
							</div>
						{/for}
					</div>
				{/for}
			</div>
			<div class="list-blog-slick-carousel slick-slider slick-loading" id="{$formAtts.form_id|escape:'html':'UTF-8'}">
				{foreach from=$products item=blog name=products name=mypLoop}					
					<div class="slick-slide {if $smarty.foreach.mypLoop.index == 0} first{/if}">
						<div class="item">		                    	
<div class="blog-container">
    <div class="left-block">
        <div class="blog-image-container">
            <a class="blog_img_link" href="{$blog.link|escape:'html':'UTF-8'}" title="{$blog.title|escape:'html':'UTF-8'}">
			{if isset($formAtts.bleoblogs_sima) && $formAtts.bleoblogs_sima}
                            {if isset($formAtts) && isset($formAtts.lazyload) && $formAtts.lazyload}
                                    {* ENABLE LAZY LOAD OWL_CAROUSEL *}
				<img loading="lazy" class="img-fluid lazyOwl" src="" data-src="{if (isset($blog.preview_thumb_url) && $blog.preview_thumb_url != '')}{$blog.preview_thumb_url}{else}{$blog.preview_url}{/if}{*full url can not escape*}" 
					 alt="{if !empty($blog.legend)}{$blog.legend|escape:'html':'UTF-8'}{else}{$blog.title|escape:'html':'UTF-8'}{/if}" 
					 title="{if !empty($blog.legend)}{$blog.legend|escape:'html':'UTF-8'}{else}{$blog.title|escape:'html':'UTF-8'}{/if}" 
					 {if isset($formAtts.bleoblogs_width)}width="{$formAtts.bleoblogs_width|escape:'html':'UTF-8'}" {/if}
					 {if isset($formAtts.bleoblogs_height)} height="{$formAtts.bleoblogs_height|escape:'html':'UTF-8'}"{/if}
					  />
                            {else}
				<img loading="lazy" class="img-fluid" src="{if (isset($blog.preview_thumb_url) && $blog.preview_thumb_url != '')}{$blog.preview_thumb_url}{else}{$blog.preview_url}{/if}{*full url can not escape*}" 
					 alt="{if !empty($blog.legend)}{$blog.legend|escape:'html':'UTF-8'}{else}{$blog.title|escape:'html':'UTF-8'}{/if}" 
					 title="{if !empty($blog.legend)}{$blog.legend|escape:'html':'UTF-8'}{else}{$blog.title|escape:'html':'UTF-8'}{/if}" 
					 {if isset($formAtts.bleoblogs_width)}width="{$formAtts.bleoblogs_width|escape:'html':'UTF-8'}" {/if}
					 {if isset($formAtts.bleoblogs_height)} height="{$formAtts.bleoblogs_height|escape:'html':'UTF-8'}"{/if}
					  />
                            {/if}
			{/if}
            </a>

			
        </div>
    </div>
    <div class="right-block">
        
		

		

		<div class="blog-meta">
		{if isset($formAtts.bleoblogs_scat) && $formAtts.bleoblogs_scat}
		<div class="cat"> 
		{*<span class="icon-list">{l s='In' mod='leoelements'}</span>*}
			<a href="{$blog.category_link}{*full url can not escape*}" title="{$blog.category_title|escape:'html':'UTF-8'}">{$blog.category_title|escape:'html':'UTF-8'}</a>
		</div>
		
	{/if}
			{if isset($formAtts.bleoblogs_scre) && $formAtts.bleoblogs_scre}
					<div class="created">
						
						<time class="date" datetime="{strtotime($blog.date_add)|date_format:"%Y"}{*convert to date time*}">										
							{*{assign var='blog_date' value=strtotime($blog.date_add)|date_format:"%A"}
							{l s=$blog_date mod='leoelements'},	<!-- day of week -->*}
							{assign var='blog_day' value=strtotime($blog.date_add)|date_format:"%e"}
							{l s=$blog_day mod='leoelements'}
							{assign var='blog_month' value=strtotime($blog.date_add)|date_format:"%B"}
							{l s=$blog_month mod='leoelements'}
							{assign var='blog_date_add' value=strtotime($blog.date_add)|date_format:"%d"}<!-- day of month -->
							
							{*{assign var='blog_daycount' value=$formAtts.leo_blog_helper->string_ordinal($blog_date_add)}
							{l s=$blog_daycount mod='leoelements'}*}
							,
							{assign var='blog_year' value=strtotime($blog.date_add)|date_format:"%Y"}						
							{l s=$blog_year mod='leoelements'}	<!-- year -->
						</time>
					</div>
				{/if}
			{if isset($formAtts.bleoblogs_saut) && $formAtts.bleoblogs_saut}
				<div class="author">
					<span class="icon-author"> {l s='By' d='Shop.Theme.Global'}</span>
					{if isset($blog.author_name) && $blog.author_name != ''} {$blog.author_name|escape:'html':'UTF-8'}{else} {$blog.author|escape:'html':'UTF-8'}{/if}
				</div>
				
			{/if}
			
			


			

			
			{if isset($formAtts.bleoblogs_scoun) && $formAtts.bleoblogs_scoun}
				<span class="nbcomment">
					<span class="icon-comment"><i class="fa-light fa-messages"></i> {l s='Comment' mod='leoelements'}:</span> {$blog.comment_count|intval}
				</span>
			{/if}
			
			{if isset($formAtts.bleoblogs_shits) && $formAtts.bleoblogs_shits}
				<span class="hits">
					<span class="icon-hits"> {l s='Hits' mod='leoelements'}:</span> {$blog.hits|intval}
				</span>	
			{/if}
		</div>

		{if isset($formAtts.show_blog_name) && $formAtts.show_blog_name}
        	<h5 class="blog-title"><a href="{$blog.link}{*full url can not escape*}" title="{$blog.title|escape:'html':'UTF-8'}">{$blog.title|strip_tags:'UTF-8'|truncate:80:'...'}</a></h5>
        {/if}

		{if isset($formAtts.show_desc) && $formAtts.show_desc}
	        <p class="blog-desc">
	            {$blog.description|strip_tags:'UTF-8'|truncate:160:'...'}
	        </p>
                {/if}


				{if isset($formAtts.bleoblogs_readmore) && $formAtts.bleoblogs_readmore}
                    <div>
                        <a class="blog-readmore" href="{$blog.link}{*full url can not escape*}" title="{$blog.title|escape:'html':'UTF-8'}">{l s='Read more' mod='leoelements'}</a>
                    </div>
                {/if}
                
    </div>
	
	<div class="hidden-xl-down hidden-xl-up datetime-translate">
		{l s='Sunday'  mod='leoelements'}
		{l s='Monday'  mod='leoelements'}
		{l s='Tuesday'  mod='leoelements'}
		{l s='Wednesday'  mod='leoelements'}
		{l s='Thursday'  mod='leoelements'}
		{l s='Friday'  mod='leoelements'}
		{l s='Saturday'  mod='leoelements'}
		
		{l s='January'  mod='leoelements'}
		{l s='February'  mod='leoelements'}
		{l s='March'  mod='leoelements'}
		{l s='April'  mod='leoelements'}
		{l s='May'  mod='leoelements'}
		{l s='June'  mod='leoelements'}
		{l s='July' mod='leoelements'}
		{l s='August' mod='leoelements'}
		{l s='September' mod='leoelements'}
		{l s='October' mod='leoelements'}
		{l s='November' mod='leoelements'}
		{l s='December' mod='leoelements'}
		
		{l s='st' mod='leoelements'}
		{l s='nd' mod='leoelements'}
		{l s='rd' mod='leoelements'}
		{l s='th' mod='leoelements'}
	</div>
</div>                                
						</div>
					</div>	               
				{/foreach}
				
			</div>
		</div>
	{else}
		<p class="alert alert-info">{l s='No products at this time.' mod='leoelements'}</p>	
	{/if}
{/if}

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
				autoplaySpeed: {if isset($formAtts.autoplay_speed) && $formAtts.autoplay_speed}{$formAtts.autoplay_speed}{else}2000{/if},
                                speed: {if isset($formAtts.speed) && $formAtts.speed}{$formAtts.speed}{else}500{/if},
				arrows: {if $formAtts.slick_arrows}true{else}false{/if},
				rows: {$formAtts.per_col},
				slidesToShow: {$formAtts.slides_to_show},
				slidesToScroll: {if $formAtts.slick_dot}{$formAtts.slides_to_show}{else}{$formAtts.slides_to_scroll}{/if},
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
                {/if}
            {else}
                <p class="alert alert-info">{l s='No blog at this time.' mod='leoelements'}</p>	
            {/if}
            {if isset($formAtts.bleoblogs_show) && $formAtts.bleoblogs_show}
                <div class="blog-viewall">
                    <a class="btn btn-primary btn-viewall" href="{$formAtts.leo_blog_helper->getFontBlogLink()}" title="{l s='View All' mod='leoelements'}">{l s='View All' mod='leoelements'}</a>
                </div>
            {/if}
        </div>
    </div>
{/if}



