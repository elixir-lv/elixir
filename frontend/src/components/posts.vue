<template>
  <div>
    <div class="row alerts">
      <div v-if=alerts.success class="row"><div class="col"><div class="alert success">{{alerts.success}}</div></div></div>
      <div v-if=alerts.error class="row"><div class="col"><div class="alert errorr">{{alerts.error}}</div></div></div>
    </div>

    <div class="row content posts">
			<div class="row header">
				<div class="col">
					<ul v-for="category in categories">
						<li><a :href="loading ? 'javascript:;' : category.url">{{category.title}}</a></li>
					</ul>
				</div>
			</div>
			<div class="row body">
				<div class="col s4" v-for="post in posts">
					<div class="row thumbnail">
						<div class="col">
							<a :href="loading ? 'javascript:;' : 'posts/' + post.uri" ><img :alt=post.title :src=post.img></a>
						</div>
					</div>
					<div class="row rating">
						<div class="col" v-for="i in 5">
							<a href="javascript:;"><img alt="star" src="ui/img/star.png"></a>
						</div>
					</div>
				</div>
			</div>
			<div class="row footer">
				<div class="col">
					<ul class="pager" v-if="total_page_cnt">
						<li><a href="javascript:;">Previous</a></li>
						<template v-for="i in total_page_cnt + 1">
							<li><a :href=i>{{i}}</a></li>
						</template>
						<li><a href="javascript:;">Next</a></li>
					</ul>
				</div>
			</div>
    </div>
  </div>
</template>
<script>
	export default {
		data() {
			return {loading: true, alerts: {success: '', error: ''},
				posts: [], categories: [], total_page_cnt: 0}
		},
		created() {
			this.getPosts();
		},
		methods: {
			getPosts: function () {
				this.clearAlerts();
				this.loading = true;
//				
//				this.$http.get('/posts').then(
//								function(response){console.log('ok', response)},
//								function(response){console.log('NOok', response)}
//				);
//
//				// TODO: Replace this with a real API call.
//				this.posts = [
//					{uri: 'post-1', img: '', title: 'Post 1', rating: 5},
//					{uri: 'post-2', img: '', title: 'Post 2', rating: 2}
//				];
				this.total_page_cnt = 2;
				this.categories = [
					{uri: 'cat-1', img: '', title: 'cat 1', rating: 5},
					{uri: 'cat-2', img: '', title: 'cat 2', rating: 2}
				];
//				this.loading = false;
//				return true;
				this.$http.get('http://api.elixir.local:4000/api/posts').then(function (response) {
					console.log(response.data
									)	
					this.posts = response.data.data;
					this.loading = false
				}, function () {
					console.log(response, 'sss')
					this.showError(response.data.error)
				});
			},
			clearAlerts: function () {
				this.alerts.success = '', this.alerts.error = ''
			},
			showSuccess: function (success = "Saved!") {
				this.alerts.success = this.getTranslatedMessage(success);
				this.loading = false
			},
			showError: function (error = "Sorry, but there's a problem.") {
				this.alerts.error = this.getTranslatedMessage(error);
				this.loading = false
			},
			getTranslatedMessage: function (messageKey) {
				return this.doesTranslationExist(messageKey) ? window.translations[messageKey] : messageKey
			},
			doesTranslationExist(messageKey) {
				return messageKey && typeof window.translations[messageKey] != "undefined" && window.translations[messageKey] != null
			}
		}
	}
</script>