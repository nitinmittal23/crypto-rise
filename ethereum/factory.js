import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
  CampaignFactory,
  '0x75B91641Bd64E1F38e55f8df7D5256536d4e7FD1'
);

export default instance;
