<template>
  <div>
		<div class="row header">
			<div class="row">
				<div class="col-sm-3 logo">
					<a href="/"><img alt="Home" src="/ui/img/logo-placeholder.jpg"></a>
				</div>
				<div class="col-sm-6"></div>
				<div class="col-sm-3 search">
					<form>
						<div class="row">
							<div class="col-sm-6">
								<input class="search-input" type="text" placeholder="Seach...">
							</div>
							<div class="col-sm-3">
								<button type="submit">Search</button>
							</div>
						</div>
					</form>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-12 link-menu">
					<ul>
						<li class="float-left width-150 no-bullet"><a class href="/posts">Posts</a></li>
						<li class="float-left width-150 no-bullet"><a href="/contacts">Contacts</a></li>
						<li class="float-left width-150 no-bullet"><a href="/map">Item in a map</a></li>
						<li class="float-left width-150 no-bullet"><a href="/graphs">Graphs</a></li>
					</ul>
				</div>
			</div>
		</div>

		<slot></slot>
  </div>
</template>
<script>export default {name: 'default-layout'}</script>
