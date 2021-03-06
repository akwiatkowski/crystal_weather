class MetarBox extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      data: []
    }
  }

  loadDataFromServer() {
    fetch(this.props.url)
      .then( response => response.json() )
      .then(data => this.setState({ data: data }))
      .catch(err => console.error(this.props.url, err.toString()))
  }

  componentDidMount() {
    this.loadDataFromServer();
    setInterval(this.loadDataFromServer.bind(this), this.props.pollInterval);
  }

  render() {
    return (
      <div>
        <h1>METARs</h1>
        <MetarWeatherTable data={this.state.data}/>
      </div>
    );
  }
}

class MetarWeatherRow extends React.Component {
  render() {
    return (
      <tr key={this.props.data.metar} title={this.props.data.metar_string}>
        <td>{this.props.data.metar}</td>
        <td>{this.props.data.city}</td>
        <td>{this.props.data.country}</td>
        <td><a href={"http://www.openstreetmap.org/#map=12/" + this.props.data.lat + "/" +  this.props.data.lon} target="_blank">{this.props.data.lat}, {this.props.data.lon}</a></td>
        <td>{moment.unix(this.props.data.time_from).format("MM-DD")}</td>
        <td>{moment.unix(this.props.data.time_from).format("HH:mm")}</td>
        <td>{moment.unix(this.props.data.time_to).format("HH:mm")}</td>
        <td>{this.props.data.temperature} C</td>
        <td>{Math.round(this.props.data.wind, 2)} m/s</td>
        <td>{this.props.data.pressure} hPa</td>
        <td>{this.props.data.clouds} %</td>
        <td>{this.props.data.rain_metar}</td>
        <td>{this.props.data.snow_metar}</td>

      </tr>
    );
  }
}

class MetarWeatherTable extends React.Component {
  render() {
    var metarNodes = this.props.data.map((metar) => {
      return (
        <MetarWeatherRow data={metar}></MetarWeatherRow>
      );
    });
    return (
      <div>
        <table className="weather metar">
          <tbody>
            <tr>
              <th>Metar</th>
              <th>City</th>
              <th>Country</th>
              <th>Coords</th>
              <th>Date</th>
              <th>From</th>
              <th>To</th>
              <th>Temperature</th>
              <th>Wind</th>
              <th>Pressure</th>
              <th>Clouds</th>
              <th>Rain</th>
              <th>Snow</th>
      
            </tr>
            {metarNodes}
          </tbody>
        </table>
      </div>
    );
  }
}

ReactDOM.render(<MetarBox url="metar.json" pollInterval={1800000} />, document.getElementById('content'));
