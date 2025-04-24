使用yarn初始化项目，生成package.json
yarn init

修改package.json文件，方便使用 yarn start files
{
  "name": "task4",
  "version": "1.0.0",
  "description": "task4 learn",
  "main": "index.js",
  "scripts": {
    "start": "ts-node",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "vincent",
  "license": "MIT",
  "devDependencies": {
    "ts-node": "^10.9.2",
    "typescript": "^5.8.3"
  },
  "dependencies": {
    "ethers": "^6.13.5",
    "viem": "^2.26.3"
  }
}

安装hardhat
yarn add --dev hardhat

安装 package.json 中的包
yarn install

安装 ts-node
yarn add --dev ts-node typescript

构建 tsconfig.json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  }
}

启动本地网络节点
npx hardhat node



