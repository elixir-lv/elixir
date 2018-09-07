import Vue from 'vue';
import router from "./router";
import App from './App.vue';
import VueResource from "vue-resource";
Vue.use(VueResource);

Vue.options.http.root = 'http://api.elixir.local';
new Vue(router, render: h => h(App)}).$mount("#app");
