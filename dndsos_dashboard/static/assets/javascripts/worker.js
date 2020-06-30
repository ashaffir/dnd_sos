// Reference: https://www.youtube.com/watch?v=HcSqj1apNHI
console.log('HERE');
self.addEventListener('message', function(event){
    console.log(event.data);
    if (event.data.type === 'coords'){
        console.log('Sending coordinates back...')
        // let count = 0;
        // for (let i = 0; i < 100; i++){
        //     count += i;
        // }
        let lat =  event.data.lat;
        let lon =  event.data.lon;
        self.postMessage({message:{
            lat: lat,
            lon:lon
        } });
    }
})