<template>
  <div>
    <div class="row alerts">
      <div v-if=alerts.success class="row"><div class="col-sm-12"><div class="alert success">{{alerts.success}}</div></div></div>
      <div v-if=alerts.error class="row"><div class="col-sm-12"><div class="alert errorr">{{alerts.error}}</div></div></div>
    </div>

    <div class="row content post">
			<div class="row header">
				<div class="breadcrumbs col">
					<ul>
						<li class="horizontal width-150"><a href="">Home</a> <span class="breadcrump-seperator">></span></li>
						<li class="horizontal width-150"><a href="/posts">Category 1</a> <span class="breadcrump-seperator">></span></li>
						<li class="horizontal width-150">Post 1</li>
					</ul>
				</div>
			</div>
			<div class="row body">
				<div class="col-sm-12">
					<div class="row title">
						<div class="col-sm-12">
							<h1>{{post.title}}</h1>
						</div>
					</div>
					<div class="row thumbnail">
						<div class="col-sm-12">
							<img :alt=post.title :src=post.img>
						</div>
					</div>
					<div class="row rating">
						<div class="col-sm-12">
							<ul v-for="i in post.rating">
								<li class="horizontal width-50"><img alt="star" src="ui/img/star.png"></li>
							</ul>
						</div>
					</div>
					<div class="row text">
						<div class="col-sm-12">
							{{post.text}}
						</div>
					</div>
					<div class="row share">
						<div class="col-sm-12">
							<a href="javascript:;">Share</a>
						</div>
					</div>
				</div>
			</div>
    </div>
  </div>
</template>
<script>
	export default {
		data() {
			return {loading: true, alerts: {success: '', error: ''}, id: 0, post: {}}
		},
		created() {
			this.getPost();
		},
		methods: {
			getPost: function () {
				this.clearAlerts();
				this.loading = true;

//				// TODO: Replace this with a real API call.
//				this.post = {uri: 'post-1', img: '', title: 'Post 1', rating: 2, text: 'Lorem ipsum post 1'};
//				this.loading = false;
//				return true;

				this.$http.get('posts/' + this.id).then(function (response) {
					this.post = response.data.data;
					this.loading = false
				}, function () {
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