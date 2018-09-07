import Vue from 'vue';
import router from "./router";
import App from './App.vue';
import VueResource from "vue-resource";
Vue.use(VueResource);

Vue.http.options.root = 'http://api.elixir.local:4000/api/';
new Vue({router, render: h => h(App)}).$mount("#app");
