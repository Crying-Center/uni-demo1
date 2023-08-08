<template>
	<!-- template标签不可少 -->
	<!-- view在vue2中只能有一个盒子 div只限于开发H5，不能开发小程序和App-->
	<!-- <div class="box"> -->
		<!-- 微信小程序无法兼容H5标签语法 -->
		<!-- <h1>你好，我要学<span class="row">Uni-App</span></h1> -->
		<!-- <view>我是最强的</view> -->
		<!-- <h1>我应该是加粗的</h1> -->
	<!-- </div> -->
	
	<view class="out">
		<view class="box"></view>
		<view class="block"></view>
		<!-- icon是行排列的标签，view是块标签（div） -->
		<icon type="success" size="26"/>	
		<icon type="waiting" size="26"/>
		<text>我是</text>	<!-- text就是span标签的替代，也是行标签 -->
		<text selectable space="ensp">章佳     &gt;     煌</text>
		<scroll-view class="scroll" scroll-x scroll-y enable-back-to-top> <!-- scroll-x允许横向滚动 -->
			<view class="group">
				<view class="item">111</view>
				<view class="item">222</view>
				<view class="item">333</view>
				<view class="item">444</view>
				<view class="item">555</view>
			</view>
		</scroll-view>
			
		<swiper autoplay indicator-dots circular interval="3000" indicator-color="#f3f6e5" indicator-active-color="blue">
			<!-- 滑块视图容器 轮播图 -->
			<swiper-item><image src="/static/images/banner1.png"></image></swiper-item>
			<swiper-item><image src="/static/images/banner2.png"></image></swiper-item>
			<swiper-item><image src="/static/images/banner3.png"></image></swiper-item>
		</swiper>
		
		<image src="../../static/logo.png" class="myimg" draggable>	<!-- image标签区别于img，其具有默认宽高 -->
		<image src="../../static/images/pic1.png" class="mypic" mode="aspectFill"></image><!-- aspectFit:完全显示图片，整体压缩，aspectFill:截取图片（朋友圈图片的模式） -->
		
		<img src="../../static/logo.png">
		
		<!-- <view class="box2">
			<video src="/static/video1.mp4" :controls="false"></video>
		</view> -->
		
		<button size="mini">提交</button>
		<button size="mini" type="primary">提交</button>
		<button size="mini" type="warn">提交</button>
		<button size="mini" type="warn"><navigator url="../about/about" open-type="redirect">关于我们</navigator></button>
		<button size="mini" type="warn" plain loading>提交</button>
		<input password/>
		
		<navigator url="../list/list">新闻列表</navigator>
		
		<navigator url="../about/about" open-type="redirect">关于我们</navigator> <!-- open-type：redirect会关闭当前页，使打开的页面没有返回按钮 -->
		
	</view>
</template>

<script>
	export default {
		
	}
</script>

<!-- scss是css的加强 -->
<style lang="scss">
// .box{
// 	height: 200px;
// 	width: 300px;
// 	background: pink;
// 	h1{
// 		font-size: 30px;
// 		color: red;
// 		.row{
// 			font-style: italic;
// 		}
// 	}
// }
.out{
	.box{
		width: 200px;
		height: 200px;
		background-color: pink;
	}
	.block{
		width: 750rpx;	// 根据屏幕宽度自适应的动态单位。以 750 宽的屏幕为基准
		height: 200rpx;
		background-color: green;
	}
	swiper-item{
		background-color: pink;
	}
}

.scroll{
	border: 1px solid red;
	box-sizing: border-box;	// 内边框
	height: 100rpx;
	.group{
		white-space: nowrap;	// 不换行
		.item{
			width: 220rpx;
			height: 220rpx;
			background-color: skyblue;
			display: inline-block;
			margin-right: 10rpx;
		}
	}
}

.myimg{
	width: 260rpx;
	height: 260rpx;
}

.mypic{
	width: 300;
	height: 300rpx;
}

.box2{
	height: 200rpx;
}
</style>
