class WeatherBox extends React.Component {
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
        <h1>Regular weather</h1>
        <WeatherTable data={this.state.data}/>
      </div>
    );
  }
}

class WeatherRow extends React.Component {
  render() {
    return (
      <tr key={this.props.data.metar}>
        <td>{this.props.data.city}</td>
        <td>{this.props.data.country}</td>
        <td><a href={"http://www.openstreetmap.org/#map=12/" + this.props.data.lat + "/" +  this.props.data.lon} target="_blank">{this.props.data.lat}, {this.props.data.lon}</a></td>
        <td>{moment.unix(this.props.data.time_from).format("MM-DD")}</td>
        <td>{moment.unix(this.props.data.time_from).format("HH:mm")}</td>
        <td>{moment.unix(this.props.data.time_to).format("HH:mm")}</td>
        <td>{this.props.data.temperature} C</td>
        <td>{this.props.data.wind_chill} C</td>

        <td>{Math.round(this.props.data.wind, 2)} m/s</td>
        <td>{this.props.data.pressure} hPa</td>
        <td>{this.props.data.clouds}</td>
        <td>{this.props.data.rain_mm} mm</td>
        <td>{this.props.data.snow_mm} mm</td>
      </tr>
    );
  }
}

class WeatherTable extends React.Component {
  render() {
    var weatherNodes = this.props.data.map((weather) => {
      return (
        <WeatherRow data={weather}></WeatherRow>
      );
    });
    return (
      <div>
        <table className="weather regular-weather">
          <tbody>
            <tr>
              <th>City</th>
              <th>Country</th>
              <th>Coords</th>
              <th>Date</th>
              <th>From</th>
              <th>To</th>
              <th>Temperature</th>
              <th>Wind chill</th>
              <th>Wind</th>
              <th>Pressure</th>
              <th>Clouds</th>
              <th>Rain</th>
              <th>Snow</th>
            </tr>
            {weatherNodes}
          </tbody>
        </table>
      </div>
    );
  }
}

ReactDOM.render(<WeatherBox url="weather.json" pollInterval={3600000} />, document.getElementById('content'));
