<template>
  <div>
    <div class="row alerts">
      <div v-if=alerts.success class="row"><div class="col"><div class="alert success">{{alerts.success}}</div></div></div>
      <div v-if=alerts.error class="row"><div class="col"><div class="alert errorr">{{alerts.error}}</div></div></div>
    </div>

    <div class="row content map">
			<div class="row body">
				<div class="col">
					<div class="row title">
						<div class="col">
							<h1>{{map.title}}</h1>
						</div>
					</div>
					<div class="row thumbnail">
						<div class="col">
							<img :alt=map.title :src=map.img>
						</div>
					</div>
					<div class="row rating">
						<!--						<div class="col" v-while="$i < map.rating">
													<a href="javascript:;"><img alt="star" src="ui/img/star.png"></a>
												</div>-->
					</div>
					<div class="row text">
						<div class="col">
							{{map.text}}
						</div>
					</div>
					<div class="row share">
						<div class="col">
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
			return {loading: true, alerts: {success: '', error: ''}, map: {}}
		},
		created() {
			this.getMap();
		},
		methods: {
			getMap: function () {
				this.clearAlerts();
				this.loading = true;

				// TODO: Replace this with a real API call.
				this.map = {uri: 'map-1', img: '', title: 'Map 1', rating: 2, text: 'Lorem ipsum map 1'};
				this.loading = false;
				return true;

				this.get('maps/' + this.id).then(function (response) {
					this.map = response.data.data;
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