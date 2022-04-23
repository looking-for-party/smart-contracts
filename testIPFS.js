const ipfsAPI = require("ipfs-api");
const ipfs = ipfsAPI("ipfs.infura.io", "5001", { protocol: "https" });
ipfs.files.get(
  "QmQcVsiNeVtAuVJEM1QeG2AX5h9TmpyHx1p4PKXhsBybYe",
  function (err, files) {
    if (err) console.log("err : ", err);
    files.forEach((file) => {
      console.log(file.path);
      console.log(file);
    });
  }
);
