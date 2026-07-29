{* 
* @Module Name: Leo Blog
* @Website: leotheme.com.com - prestashop template provider
* @author Leotheme <leotheme@gmail.com>
* @copyright  Leotheme
* @description: Content Management
*}

<article class="blog-item">
	<div class="blog-image-container">
		
		{if Configuration::get('LEOBLOG_SHARE_FB') || Configuration::get('LEOBLOG_SHARE_TW') }
			<div class="share_button">
				<span><i class="fa fa-share-alt"></i>{l s='Share' mod='leoblog'}</span>
				<ul>
					{if Configuration::get('LEOBLOG_SHARE_FB')}
						<li class="facebook">
							<a href="http://www.facebook.com/sharer.php?u={$smarty.server.HTTP_HOST|escape:'htmlall':'UTF-8'}{$smarty.server.REQUEST_URI|escape:'htmlall':'UTF-8'}">
								<span>{l s='Facebook' mod='leoblog'}</span>
							</a>
						</li>
					{/if}
					{if Configuration::get('LEOBLOG_SHARE_TW')}
						<li class="twitter">
							<a href="https://twitter.com/intent/tweet?text={$smarty.server.HTTP_HOST|escape:'htmlall':'UTF-8'}{$smarty.server.REQUEST_URI|escape:'htmlall':'UTF-8'}">
								<span>{l s='Twitter' mod='leoblog'}</span>
							</a>
						</li>
					{/if}
				</ul>
			</div>
		{/if}

		{if $blog.image && $config->get('listing_show_image',1)}
		<div class="blog-image">
			<a href="{$blog.link|escape:'html':'UTF-8'}" title="{$blog.title|escape:'html':'UTF-8'}">
				<img loading="lazy"  {if isset($aplazyload) && $aplazyload}data-src{else}src{/if}="{$blog.preview_url|escape:'html':'UTF-8'}" title="{$blog.title|escape:'html':'UTF-8'}" alt="{$blog.title|escape:'html':'UTF-8'}" class="img-fluid{if isset($aplazyload) && $aplazyload} lazy{/if}" />
			</a>
		</div>
		{/if}


		
		
	</div>
	<div class="blog-info">

		

		

		<div class="blog-meta">

			{if $config->get('listing_show_category','1')}
			<div class="blog-cat"> 
				{*<i class="material-icons">list</i> <span>{l s='In' mod='leoblog'}:</span> *}
				<a href="{$blog.category_link|escape:'html':'UTF-8'}" title="{$blog.category_title|escape:'html':'UTF-8'}">{$blog.category_title|escape:'html':'UTF-8'}</a>
			</div>
		{/if}

			
			
			
			
			{if $config->get('listing_show_created','1')}
				<span class="blog-created">
					{*<i class="material-icons">&#xE192;</i> <span>{l s='On' mod='leoblog'}: </span>*} 
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
				</span>
			{/if}

			{if $config->get('listing_show_author','1')&&!empty($blog.author)}
				<span class="blog-author">
					{*<i class="material-icons">person</i>*}  <span>{l s='By' mod='leoblog'}</span>
					<a href="{$blog.author_link|escape:'html':'UTF-8'}" title="{$blog.author|escape:'html':'UTF-8'}">{$blog.author|escape:'html':'UTF-8'}</a> 
				</span>
			{/if}
			
			{if isset($blog.comment_count)&&$config->get('listing_show_counter','1')}	
				<span class="blog-ctncomment">
					<i class="material-icons">comment</i> <span>{l s='Comment' mod='leoblog'}:</span> 
					{$blog.comment_count|intval}
				</span>
			{/if}

			{if $config->get('listing_show_hit','1')}	
				<span class="blog-hit">
					<i class="material-icons">favorite</i> <span>{l s='Hit' mod='leoblog'}:</span> 
					{$blog.hits|intval}
				</span>
			{/if}
		</div>

		{if $config->get('listing_show_title','1')}
			<h4 class="title">
				<a href="{$blog.link|escape:'html':'UTF-8'}" title="{$blog.title|escape:'html':'UTF-8'}">{$blog.title|escape:'html':'UTF-8'}</a>
			</h4>
		{/if}

		{if $config->get('listing_show_description','1')}
			<div class="blog-shortinfo">
				{$blog.description|strip_tags:'UTF-8'|truncate:160:'...'|cleanHtml nofilter}{* HTML form , no escape necessary *}
			</div>
		{/if}
		{if $config->get('listing_show_readmore',1)}
			<p>
				<a href="{$blog.link|escape:'html':'UTF-8'}" title="{$blog.title|escape:'html':'UTF-8'}" class="more btn btn-primary">{l s='Read more' mod='leoblog'}</a>
			</p>
		{/if}
	</div>
	
	<div class="hidden-xl-down hidden-xl-up datetime-translate">
		{l s='Sunday' mod='leoblog'}
		{l s='Monday' mod='leoblog'}
		{l s='Tuesday' mod='leoblog'}
		{l s='Wednesday' mod='leoblog'}
		{l s='Thursday' mod='leoblog'}
		{l s='Friday' mod='leoblog'}
		{l s='Saturday' mod='leoblog'}
		
		{l s='January' mod='leoblog'}
		{l s='February' mod='leoblog'}
		{l s='March' mod='leoblog'}
		{l s='April' mod='leoblog'}
		{l s='May' mod='leoblog'}
		{l s='June' mod='leoblog'}
		{l s='July' mod='leoblog'}
		{l s='August' mod='leoblog'}
		{l s='September' mod='leoblog'}
		{l s='October' mod='leoblog'}
		{l s='November' mod='leoblog'}
		{l s='December' mod='leoblog'}
					
	</div>
</article>
